import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Connection, Model, Types } from 'mongoose';
import { InjectConnection } from '@nestjs/mongoose';
import { RecipesService } from '../recipes/recipes.service';
import { User, UserDocument } from '../users/schemas/user.schema';
import { CreateOrderDto } from './dto/create-order.dto';
import { Order, OrderDocument } from './schemas/order.schema';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name)
    private readonly orderModel: Model<OrderDocument>,
    @InjectModel(User.name)
    private readonly userModel: Model<UserDocument>,
    private readonly recipesService: RecipesService,
    @InjectConnection() private readonly connection: Connection,
  ) {}

  async purchase(userId: string, dto: CreateOrderDto) {
    const [recipe, user, existing] = await Promise.all([
      this.recipesService.findRawById(dto.recipeId),
      this.userModel.findById(userId).lean(),
      this.orderModel
        .findOne({
          userId: new Types.ObjectId(userId),
          recipeIds: new Types.ObjectId(dto.recipeId),
          status: 'Completed',
        })
        .lean(),
    ]);

    if (!user) throw new BadRequestException('User account not found');
    const alreadyOwned = (user.purchasedRecipeIds ?? []).some(
      (id) => id.toString() === dto.recipeId,
    );
    if (existing || alreadyOwned) {
      throw new ConflictException('Recipe already purchased');
    }

    const price = Number(recipe.price ?? 0);
    const badge = String(recipe.badge ?? '');
    if (price <= 0 || badge === 'Free') {
      throw new BadRequestException(
        'This recipe does not require an individual purchase',
      );
    }
    if (badge === 'Pro' && !user.isPro) {
      throw new BadRequestException(
        'Only E-Recipe Pro members can purchase Pro recipes',
      );
    }
    if (Number(dto.amount) !== price) {
      throw new BadRequestException('The payment amount does not match the recipe price');
    }

    const recipeId = new Types.ObjectId(dto.recipeId);
    const order = await this.orderModel.create({
      orderNumber: this.createOrderNumber(),
      customer:
        user.fullName ||
        `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim() ||
        user.email,
      item: `${recipe.title} x1`,
      items: [
        {
          recipeId,
          title: recipe.title,
          quantity: 1,
          unitPrice: price,
        },
      ],
      price,
      userId: new Types.ObjectId(userId),
      format: 'digital',
      recipeIds: [recipeId],
      status: 'Completed',
      paymentMethod: 'e-Sewa',
      paymentAccountMasked: `******${dto.esewaNumber.slice(-4)}`,
    });

    await this.userModel.findByIdAndUpdate(userId, {
      $addToSet: { purchasedRecipeIds: recipeId },
    });
    const now = new Date();
    await this.connection.collection('notifications').insertOne({
      userId: new Types.ObjectId(userId),
      broadcast: false,
      message: `You purchased ${recipe.title}. Tap to start cooking!`,
      type: 'purchase',
      action: 'open_recipe',
      recipeId,
      read: false,
      createdAt: now,
      updatedAt: now,
    });

    return this.toApiOrder(order.toObject(), recipe);
  }

  async findMine(userId: string) {
    const orders = await this.orderModel
      .find({ userId: new Types.ObjectId(userId), status: 'Completed' })
      .sort({ createdAt: -1 })
      .lean();

    return Promise.all(
      orders.map(async (order) => {
        const recipeId =
          order.recipeIds?.[0]?.toString() ??
          order.items?.[0]?.recipeId?.toString();
        if (!recipeId) return null;
        try {
          const recipe = await this.recipesService.findRawById(recipeId);
          return this.toApiOrder(order, recipe);
        } catch {
          return null;
        }
      }),
    ).then((items) => items.filter(Boolean));
  }

  private toApiOrder(order: Record<string, any>, recipe: Record<string, any>) {
    return {
      id: String(order._id),
      orderNumber: order.orderNumber,
      recipe: this.recipesService.toApiRecipe(recipe, true),
      price: Number(order.price ?? recipe.price ?? 0),
      purchasedAt: order.createdAt ?? new Date(),
      paymentMethod: order.paymentMethod ?? 'e-Sewa',
      paymentAccountMasked: order.paymentAccountMasked ?? '',
      status: order.status ?? 'Completed',
    };
  }

  private createOrderNumber() {
    return `ORD-${Date.now().toString(36).toUpperCase()}-${Math.random()
      .toString(36)
      .slice(2, 6)
      .toUpperCase()}`;
  }
}
