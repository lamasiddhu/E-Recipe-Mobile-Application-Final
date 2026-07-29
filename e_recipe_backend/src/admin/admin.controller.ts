import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';
import { AdminService } from './admin.service';

@Controller('admin')
@UseGuards(JwtAuthGuard)
export class AdminController {
  constructor(private readonly service: AdminService) {}

  private check(user: any) {
    this.service.assertAdmin(user);
  }

  @Get('dashboard')
  dashboard(@CurrentUser() user: any) {
    this.check(user);
    return this.service.dashboard();
  }

  @Get('users')
  users(@CurrentUser() user: any) {
    this.check(user);
    return this.service.users();
  }

  @Patch('users/:id')
  updateUser(
    @CurrentUser() user: any,
    @Param('id', ParseObjectIdPipe) id: string,
    @Body() body: { role?: string; isPro?: boolean },
  ) {
    this.check(user);
    return this.service.updateUser(id, body);
  }

  @Delete('users/:id')
  async deleteUser(
    @CurrentUser() user: any,
    @Param('id', ParseObjectIdPipe) id: string,
  ) {
    this.check(user);
    await this.service.deleteUser(id, user._id.toString());
    return { success: true };
  }

  @Post('users/:id/notification')
  notify(
    @CurrentUser() user: any,
    @Param('id', ParseObjectIdPipe) id: string,
    @Body() body: { message: string; action?: string },
  ) {
    this.check(user);
    return this.service.notifyUser(id, body.message, body.action);
  }

  @Post('users/:id/recovery')
  recovery(
    @CurrentUser() user: any,
    @Param('id', ParseObjectIdPipe) id: string,
  ) {
    this.check(user);
    return this.service.recovery(id);
  }

  @Delete('users/:userId/purchases/:recipeId')
  removePurchase(
    @CurrentUser() user: any,
    @Param('userId', ParseObjectIdPipe) userId: string,
    @Param('recipeId', ParseObjectIdPipe) recipeId: string,
  ) {
    this.check(user);
    return this.service.removePurchase(userId, recipeId);
  }

  @Get('orders')
  orders(@CurrentUser() user: any) {
    this.check(user);
    return this.service.orders();
  }

  @Get('settings')
  settings(@CurrentUser() user: any) {
    this.check(user);
    return this.service.settings();
  }

  @Patch('settings/maintenance')
  maintenance(
    @CurrentUser() user: any,
    @Body() body: { enabled: boolean },
  ) {
    this.check(user);
    return this.service.maintenance(body.enabled);
  }

  @Post('settings/clear-cache')
  clearCache(@CurrentUser() user: any) {
    this.check(user);
    return this.service.clearCache();
  }

  @Post('broadcast')
  broadcast(
    @CurrentUser() user: any,
    @Body() body: { message: string; type?: string },
  ) {
    this.check(user);
    return this.service.broadcast(body.message, body.type);
  }
}

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly service: AdminService) {}

  @Get('my')
  my(@CurrentUser() user: any) {
    return this.service.myNotifications(user._id.toString());
  }

  @Patch('read-all')
  readAll(@CurrentUser() user: any) {
    return this.service.markAllRead(user._id.toString());
  }

  @Delete('clear-all')
  clearAll(@CurrentUser() user: any) {
    return this.service.clearAll(user._id.toString());
  }

  @Patch(':id/read')
  read(
    @CurrentUser() user: any,
    @Param('id', ParseObjectIdPipe) id: string,
  ) {
    return this.service.markRead(id, user._id.toString());
  }

  @Patch(':id/reset-password')
  resetPassword(
    @CurrentUser() user: any,
    @Param('id', ParseObjectIdPipe) id: string,
    @Body() body: { token: string; newPassword: string },
  ) {
    return this.service.resetPassword(
      id,
      user._id.toString(),
      body.token,
      body.newPassword,
    );
  }
}
