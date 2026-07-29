import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Connection, Model, Types } from 'mongoose';
import { InjectConnection } from '@nestjs/mongoose';
import { Recipe, RecipeDocument } from './schemas/recipe.schema';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { UpdateRecipeDto } from './dto/update-recipe.dto';
import { FindRecipesQueryDto } from './dto/find-recipes-query.dto';
import { User, UserDocument } from '../users/schemas/user.schema';

@Injectable()
export class RecipesService {
  constructor(
    @InjectModel(Recipe.name) private recipeModel: Model<RecipeDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectConnection() private connection: Connection,
  ) {}

  async create(dto: CreateRecipeDto, createdBy: Types.ObjectId) {
    const recipe = await this.recipeModel.create({ ...dto, createdBy });
    const now = new Date();
    await this.connection.collection('notifications').insertOne({
      broadcast: true,
      message: `E-Recipe has a new recipe: ${recipe.title}. Check it out!`,
      type: 'new_recipe',
      action: 'open_recipe',
      recipeId: recipe._id,
      read: false,
      createdAt: now,
      updatedAt: now,
    });
    return recipe;
  }

  async findAll(query: FindRecipesQueryDto) {
    const { category, search, difficulty, maxTime, page, limit } = query;
    const filter: Record<string, unknown> = {};

    if (category) filter.category = category;
    if (difficulty) {
      const difficultyMap: Record<string, string[]> = {
        Easy: ['Easy', 'Basic'],
        Medium: ['Medium', 'Intermediate'],
        Hard: ['Hard', 'Advanced', 'Expert'],
      };
      filter.difficulty = { $in: difficultyMap[difficulty] ?? [difficulty] };
    }
    if (maxTime) {
      filter.$or = [
        { totalTime: { $lte: maxTime } },
        {
          duration: {
            $regex: `^([0-${Math.floor(maxTime / 10)}]?\\d)\\s*min`,
            $options: 'i',
          },
        },
      ];
    }
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { ingredients: { $regex: search, $options: 'i' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.recipeModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      this.recipeModel.countDocuments(filter),
    ]);

    return { data: data.map((recipe) => this.toApiRecipe(recipe)), total };
  }

  async findAllForAdmin() {
    const recipes = await this.recipeModel.find().sort({ createdAt: -1 }).lean();
    return recipes.map((recipe) => this.toApiRecipe(recipe, true));
  }

  async findById(id: string, userId: string) {
    const [recipe, user] = await Promise.all([
      this.recipeModel.findById(id).lean(),
      this.userModel.findById(userId).lean(),
    ]);
    if (!recipe) throw new NotFoundException('Recipe not found');
    const badge = String(recipe.badge ?? 'Free');
    const isFree = badge === 'Free';
    const isOwned = (user?.purchasedRecipeIds ?? []).some(
      (recipeId) => recipeId.toString() === id,
    );
    const hasPro = Boolean(user?.isPro);
    const hasProtectedAccess =
      isOwned && (badge !== 'Pro' || hasPro);

    return {
      ...this.toApiRecipe(recipe, isFree || hasProtectedAccess),
      isOwned,
      canPurchase: badge === 'Normal' || (badge === 'Pro' && hasPro),
      requiresPro: badge === 'Pro' && !hasPro,
    };
  }

  async update(id: string, dto: UpdateRecipeDto) {
    const updated = await this.recipeModel.findByIdAndUpdate(id, dto, {
      new: true,
    });
    if (!updated) throw new NotFoundException('Recipe not found');
    return updated;
  }

  async remove(id: string) {
    const deleted = await this.recipeModel.findByIdAndDelete(id);
    if (!deleted) throw new NotFoundException('Recipe not found');
  }

  async findRawById(id: string) {
    const recipe = await this.recipeModel.findById(id).lean();
    if (!recipe) throw new NotFoundException('Recipe not found');
    return recipe as Record<string, any>;
  }

  toApiRecipe(
    recipe: Record<string, any>,
    revealProtectedContent = false,
  ) {
    const rawDifficulty = recipe.difficulty ?? 'Basic';
    const difficulty =
      rawDifficulty === 'Basic' || rawDifficulty === 'Easy'
        ? 'Easy'
        : rawDifficulty === 'Intermediate' || rawDifficulty === 'Medium'
          ? 'Medium'
          : 'Hard';
    const durationMatch = String(recipe.duration ?? '').match(/\d+/);
    const totalTime = Number(recipe.totalTime ?? durationMatch?.[0] ?? 0);
    const instructions =
      Array.isArray(recipe.instructions) && recipe.instructions.length > 0
        ? recipe.instructions
        : (recipe.steps ?? []).map(
            (step: { title?: string; description?: string }) =>
              [step.title, step.description].filter(Boolean).join(': '),
          );
    const imageSource = recipe.imageUrl ?? recipe.image ?? '';
    const imageName = imageSource
      ? String(imageSource).replace(/\\/g, '/').split('/').pop()
      : '';
    const id = String(recipe._id);
    const fallbackDate = new Types.ObjectId(id).getTimestamp();
    const badge =
      recipe.badge ?? (Number(recipe.price ?? 0) > 0 ? 'Normal' : 'Free');
    const canReveal = badge === 'Free' || revealProtectedContent;

    return {
      _id: id,
      title: recipe.title ?? '',
      description: recipe.description ?? '',
      ingredients: canReveal ? (recipe.ingredients ?? []) : [],
      instructions: canReveal ? instructions : [],
      category: recipe.category ?? 'Uncategorized',
      prepTime: recipe.prepTime,
      cookTime: recipe.cookTime,
      totalTime,
      difficulty,
      image: imageName ? `/recipes/image/${imageName}` : '',
      videoUrl: canReveal ? (recipe.videoUrl ?? recipe.youtubeUrl ?? '') : '',
      createdBy: String(recipe.createdBy ?? ''),
      createdAt: recipe.createdAt ?? fallbackDate,
      updatedAt: recipe.updatedAt ?? recipe.createdAt ?? fallbackDate,
      price: Number(recipe.price ?? 0),
      badge,
    };
  }
}
