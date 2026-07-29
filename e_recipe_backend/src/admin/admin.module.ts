import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Order, OrderSchema } from '../orders/schemas/order.schema';
import { Recipe, RecipeSchema } from '../recipes/schemas/recipe.schema';
import { User, UserSchema } from '../users/schemas/user.schema';
import { AdminController, NotificationsController } from './admin.controller';
import { AdminService } from './admin.service';
import { AppSetting, AppSettingSchema } from './schemas/app-setting.schema';
import {
  Notification,
  NotificationSchema,
} from './schemas/notification.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Order.name, schema: OrderSchema },
      { name: Recipe.name, schema: RecipeSchema },
      { name: Notification.name, schema: NotificationSchema },
      { name: AppSetting.name, schema: AppSettingSchema },
    ]),
  ],
  controllers: [AdminController, NotificationsController],
  providers: [AdminService],
})
export class AdminModule {}
