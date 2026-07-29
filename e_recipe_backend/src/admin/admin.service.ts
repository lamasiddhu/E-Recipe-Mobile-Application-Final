import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { randomBytes } from 'crypto';
import { Order, OrderDocument } from '../orders/schemas/order.schema';
import { Recipe, RecipeDocument } from '../recipes/schemas/recipe.schema';
import { User, UserDocument } from '../users/schemas/user.schema';
import {
  AppSetting,
  AppSettingDocument,
} from './schemas/app-setting.schema';
import {
  Notification,
  NotificationDocument,
} from './schemas/notification.schema';

@Injectable()
export class AdminService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(Recipe.name) private recipeModel: Model<RecipeDocument>,
    @InjectModel(Notification.name)
    private notificationModel: Model<NotificationDocument>,
    @InjectModel(AppSetting.name)
    private settingModel: Model<AppSettingDocument>,
  ) {}

  assertAdmin(user: any) {
    if (user?.role !== 'admin') {
      throw new ForbiddenException('Admin access required');
    }
  }

  async dashboard() {
    const [totalUsers, totalRecipes, pendingOrders, revenueRows, users] =
      await Promise.all([
        this.userModel.countDocuments(),
        this.recipeModel.countDocuments(),
        this.orderModel.countDocuments({ status: /^pending$/i }),
        this.orderModel.aggregate([
          {
            $match: {
              status: { $regex: /^(completed|paid|success|successful)$/i },
            },
          },
          { $group: { _id: null, total: { $sum: '$price' } } },
        ]),
        this.userModel
          .find({ role: { $ne: 'admin' } })
          .sort({ createdAt: -1 })
          .limit(5)
          .lean(),
      ]);
    const since = new Date();
    since.setDate(since.getDate() - 6);
    since.setHours(0, 0, 0, 0);
    const chartRows = await this.orderModel.aggregate([
      {
        $match: {
          createdAt: { $gte: since },
          status: { $regex: /^(completed|paid|success|successful)$/i },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt',
              timezone: 'Asia/Kathmandu',
            },
          },
          revenue: { $sum: '$price' },
          orders: { $sum: 1 },
        },
      },
    ]);
    const byDate = new Map(chartRows.map((row) => [row._id, row]));
    const chart = Array.from({ length: 7 }, (_, offset) => {
      const date = new Date(since);
      date.setDate(since.getDate() + offset);
      const key = [
        date.getFullYear(),
        String(date.getMonth() + 1).padStart(2, '0'),
        String(date.getDate()).padStart(2, '0'),
      ].join('-');
      return {
        label: date.toLocaleDateString('en-US', { weekday: 'short' }),
        revenue: Number(byDate.get(key)?.revenue ?? 0),
        orders: Number(byDate.get(key)?.orders ?? 0),
      };
    });
    return {
      totalUsers,
      totalRecipes,
      pendingOrders,
      revenue: Number(revenueRows[0]?.total ?? 0),
      chart,
      recentUsers: users.map((user) => this.toAdminUser(user)),
    };
  }

  async users() {
    const users = await this.userModel.find().sort({ createdAt: -1 }).lean();
    return users.map((user) => this.toAdminUser(user));
  }

  async updateUser(id: string, body: { role?: string; isPro?: boolean }) {
    if (body.role && !['user', 'admin'].includes(body.role)) {
      throw new BadRequestException('Role must be user or admin');
    }
    const update: Record<string, unknown> = {};
    if (body.role != null) update.role = body.role;
    if (body.isPro != null) update.isPro = body.isPro;
    const user = await this.userModel
      .findByIdAndUpdate(id, update, { new: true })
      .lean();
    if (!user) throw new NotFoundException('User not found');
    return this.toAdminUser(user);
  }

  async deleteUser(id: string, currentAdminId: string) {
    if (id === currentAdminId) {
      throw new BadRequestException('You cannot delete your own admin account');
    }
    const user = await this.userModel.findByIdAndDelete(id);
    if (!user) throw new NotFoundException('User not found');
    await Promise.all([
      this.orderModel.deleteMany({ userId: new Types.ObjectId(id) }),
      this.notificationModel.deleteMany({ userId: new Types.ObjectId(id) }),
    ]);
  }

  async notifyUser(
    id: string,
    message: string,
    action?: string,
    type = 'info',
  ) {
    if (!message?.trim()) throw new BadRequestException('Message is required');
    if (!(await this.userModel.exists({ _id: id }))) {
      throw new NotFoundException('User not found');
    }
    return this.notificationModel.create({
      userId: new Types.ObjectId(id),
      message: message.trim(),
      action,
      type,
    });
  }

  async recovery(id: string) {
    if (!(await this.userModel.exists({ _id: id }))) {
      throw new NotFoundException('User not found');
    }
    return this.notificationModel.create({
      userId: new Types.ObjectId(id),
      message:
        'An administrator requested that you secure your account. Set a new password now.',
      action: 'reset_password',
      type: 'security',
      resetToken: randomBytes(24).toString('hex'),
    });
  }

  async removePurchase(userId: string, recipeId: string) {
    const user = await this.userModel.findByIdAndUpdate(
      userId,
      { $pull: { purchasedRecipeIds: new Types.ObjectId(recipeId) } },
      { new: true },
    );
    if (!user) throw new NotFoundException('User not found');
    await this.orderModel.deleteMany({
      userId: new Types.ObjectId(userId),
      recipeIds: new Types.ObjectId(recipeId),
    });
    return this.toAdminUser(user.toObject());
  }

  async orders() {
    return this.orderModel.find().sort({ createdAt: -1 }).lean();
  }

  async settings() {
    return this.settingModel.findOneAndUpdate(
      { key: 'global' },
      { $setOnInsert: { key: 'global' } },
      { new: true, upsert: true },
    );
  }

  async maintenance(enabled: boolean) {
    return this.settingModel.findOneAndUpdate(
      { key: 'global' },
      { maintenanceMode: Boolean(enabled) },
      { new: true, upsert: true },
    );
  }

  async clearCache() {
    return this.settingModel.findOneAndUpdate(
      { key: 'global' },
      { cacheClearedAt: new Date() },
      { new: true, upsert: true },
    );
  }

  async broadcast(message: string, type = 'announcement') {
    if (!message?.trim()) throw new BadRequestException('Message is required');
    if (!['announcement', 'pro_offer'].includes(type)) {
      throw new BadRequestException('Invalid broadcast type');
    }
    await this.settingModel.findOneAndUpdate(
      { key: 'global' },
      { announcement: message.trim() },
      { upsert: true },
    );
    const userFilter =
      type === 'pro_offer'
        ? { proOffersEnabled: { $ne: false } }
        : {};
    const users = await this.userModel.find(userFilter).select('_id').lean();
    if (users.length === 0) {
      return { delivered: 0, message: 'No eligible recipients' };
    }
    await this.notificationModel.insertMany(
      users.map((user) => ({
        userId: user._id,
        broadcast: false,
        message: message.trim(),
        type,
        read: false,
        source: 'admin_broadcast',
      })),
    );
    return {
      delivered: users.length,
      message: `Broadcast delivered to ${users.length} account(s)`,
    };
  }

  async myNotifications(userId: string) {
    const user = await this.userModel
      .findById(userId)
      .select(
        'createdAt recipeUpdatesEnabled proOffersEnabled recipeUpdatesEnabledAt proOffersEnabledAt',
      )
      .lean();
    if (!user) throw new NotFoundException('User not found');
    const rawUser = user as Record<string, any>;
    const joinedAt =
      rawUser.createdAt ??
      new Types.ObjectId(userId).getTimestamp();
    const recipeUpdatesEnabled = rawUser.recipeUpdatesEnabled !== false;
    const proOffersEnabled = rawUser.proOffersEnabled !== false;
    const recipeUpdatesEnabledAt =
      rawUser.recipeUpdatesEnabledAt ?? joinedAt;
    const proOffersEnabledAt = rawUser.proOffersEnabledAt ?? joinedAt;
    const notifications = await this.notificationModel
      .find({
        $or: [
          { userId: new Types.ObjectId(userId) },
          {
            broadcast: true,
            dismissedBy: { $ne: new Types.ObjectId(userId) },
            createdAt: { $gte: joinedAt },
          },
        ],
      })
      .sort({ createdAt: -1 })
      .lean();
    return notifications.map((notification) => ({
      ...notification,
      read: notification.broadcast
        ? (notification.readBy ?? []).some((id) => id.toString() === userId)
        : notification.read,
    })).filter((notification) => {
      if (notification.type === 'new_recipe') {
        return (
          recipeUpdatesEnabled &&
          new Date(notification.createdAt) >= recipeUpdatesEnabledAt
        );
      }
      if (notification.type === 'pro_offer') {
        return (
          proOffersEnabled &&
          new Date(notification.createdAt) >= proOffersEnabledAt
        );
      }
      return true;
    });
  }

  async markRead(id: string, userId: string) {
    const existing = await this.notificationModel.findOne({
      _id: id,
      $or: [{ userId: new Types.ObjectId(userId) }, { broadcast: true }],
    });
    if (!existing) throw new NotFoundException('Notification not found');
    const notification = existing.broadcast
      ? await this.notificationModel.findByIdAndUpdate(
          id,
          { $addToSet: { readBy: new Types.ObjectId(userId) } },
          { new: true },
        )
      : await this.notificationModel.findByIdAndUpdate(
          id,
          { read: true },
          { new: true },
        );
    if (!notification) throw new NotFoundException('Notification not found');
    return notification;
  }

  async markAllRead(userId: string) {
    const objectId = new Types.ObjectId(userId);
    await Promise.all([
      this.notificationModel.updateMany(
        { userId: objectId },
        { $set: { read: true } },
      ),
      this.notificationModel.updateMany(
        { broadcast: true, dismissedBy: { $ne: objectId } },
        { $addToSet: { readBy: objectId } },
      ),
    ]);
    return { message: 'All notifications marked as read' };
  }

  async clearAll(userId: string) {
    const objectId = new Types.ObjectId(userId);
    await Promise.all([
      this.notificationModel.deleteMany({ userId: objectId }),
      this.notificationModel.updateMany(
        { broadcast: true },
        { $addToSet: { dismissedBy: objectId, readBy: objectId } },
      ),
    ]);
    return { message: 'Notifications cleared' };
  }

  async resetPassword(
    notificationId: string,
    userId: string,
    token: string,
    newPassword: string,
  ) {
    if (!newPassword || newPassword.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters');
    }
    const notification = await this.notificationModel.findOne({
      _id: notificationId,
      userId: new Types.ObjectId(userId),
      action: 'reset_password',
      resetToken: token,
    });
    if (!notification) {
      throw new BadRequestException('This password recovery request is invalid');
    }
    const user = await this.userModel.findById(userId).select('+password');
    if (!user) throw new NotFoundException('User not found');
    user.password = newPassword;
    await user.save();
    notification.read = true;
    notification.resetToken = undefined;
    notification.action = undefined;
    await notification.save();
    return { message: 'Password changed successfully' };
  }

  private toAdminUser(user: Record<string, any>) {
    return {
      id: String(user._id),
      name:
        user.fullName ||
        `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim(),
      email: user.email,
      phone: user.phone,
      role: user.role ?? 'user',
      isPro: Boolean(user.isPro),
      purchasedRecipeIds: (user.purchasedRecipeIds ?? []).map(String),
      createdAt: user.createdAt,
    };
  }
}
