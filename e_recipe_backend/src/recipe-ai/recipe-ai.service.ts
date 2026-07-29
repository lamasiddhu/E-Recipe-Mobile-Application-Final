import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { GenerateRecipeDto } from './dto/generate-recipe.dto';
import { Recipe, RecipeDocument } from '../recipes/schemas/recipe.schema';
import { RecipesService } from '../recipes/recipes.service';

type GeminiResponse = {
  candidates?: Array<{
    content?: { parts?: Array<{ text?: string }> };
  }>;
  error?: { message?: string };
};

@Injectable()
export class RecipeAiService {
  constructor(
    private readonly config: ConfigService,
    @InjectModel(Recipe.name)
    private readonly recipeModel: Model<RecipeDocument>,
    private readonly recipesService: RecipesService,
  ) {}

  async generate(dto: GenerateRecipeDto) {
    const apiKey = this.config.get<string>('GEMINI_API_KEY')?.trim();
    if (!apiKey) {
      throw new ServiceUnavailableException('AI recipe generation is not configured');
    }

    const query = dto.query.trim();
    if (!query) throw new BadRequestException('Tell us what you want to eat');

    const recipes = await this.recipeModel
      .find()
      .sort({ createdAt: -1 })
      .limit(100)
      .lean();
    if (recipes.length === 0) {
      return [];
    }

    const catalog = recipes.map((recipe) => ({
      id: String(recipe._id),
      title: recipe.title,
      description: recipe.description,
      category: recipe.category,
      ingredients: recipe.ingredients,
      difficulty: recipe.difficulty,
      totalTime: recipe.totalTime ?? recipe.duration,
      access: recipe.badge ?? (Number(recipe.price ?? 0) > 0 ? 'Normal' : 'Free'),
    }));

    const prompt = [
      'You are E-Recipe AI, a warm and helpful food-and-cooking assistant.',
      'Answer questions about recipes, cooking methods, ingredients, substitutions, food storage, meal ideas, cuisines, and kitchen safety.',
      'If the user asks about an unrelated topic, politely say you specialize in food and cooking, then offer a useful food-related direction.',
      'Never claim an allergy is safe and never give medical nutrition advice.',
      'Use the conversation history for follow-up questions.',
      `Conversation history: ${JSON.stringify(dto.history ?? [])}`,
      `Latest user message: ${query}`,
      'Return a helpful conversational answer and up to 5 relevant recipes from the supplied E-Recipe catalog.',
      'Only recommend IDs that exist in the catalog. Do not invent catalogue recipes.',
      `Catalog: ${JSON.stringify(catalog)}`,
    ]
      .join('\n');

    const response = await fetch(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: JSON.stringify({
          contents: [{ role: 'user', parts: [{ text: prompt }] }],
          generationConfig: {
            responseMimeType: 'application/json',
            responseSchema: {
              type: 'OBJECT',
              required: ['message', 'recommendations'],
              properties: {
                message: { type: 'STRING' },
                recommendations: {
                  type: 'ARRAY',
                  items: {
                    type: 'OBJECT',
                    required: ['id', 'reason'],
                    properties: {
                      id: { type: 'STRING' },
                      reason: { type: 'STRING' },
                    },
                  },
                },
              },
            },
          },
        }),
        signal: AbortSignal.timeout(45000),
      },
    );

    const payload = (await response.json()) as GeminiResponse;
    if (!response.ok) {
      throw new BadGatewayException(
        payload.error?.message ?? 'Gemini could not generate a recipe',
      );
    }

    const text = payload.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) throw new BadGatewayException('Gemini returned an empty recipe');

    try {
      const parsed = JSON.parse(text) as {
        message?: string;
        recommendations?: Array<{ id?: string; reason?: string }>;
      };
      const byId = new Map(recipes.map((recipe) => [String(recipe._id), recipe]));
      const recommendations = (parsed.recommendations ?? [])
        .map((item) => {
          const recipe = item.id ? byId.get(item.id) : undefined;
          if (!recipe) return null;
          return {
            recipe: this.recipesService.toApiRecipe(recipe),
            reason: item.reason?.trim() || 'Matches what you are looking for.',
          };
        })
        .filter(Boolean);
      return {
        message:
          parsed.message?.trim() ||
          'Tell me what kind of food you would like to cook.',
        recommendations,
      };
    } catch {
      throw new BadGatewayException('Gemini returned an invalid recipe');
    }
  }
}
