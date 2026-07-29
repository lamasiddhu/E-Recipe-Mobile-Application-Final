import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { join } from 'path';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { NotificationPreferencesDto } from './dto/notification-preferences.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { GoogleLoginDto } from './dto/google-login.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register')
  @Public()
  async register(@Body() dto: CreateUserDto) {
    return { success: true, data: await this.usersService.register(dto) };
  }

  @Post('login')
  @Public()
  async login(@Body() dto: LoginUserDto) {
    return this.usersService.login(dto);
  }

  @Post('google')
  @Public()
  google(@Body() dto: GoogleLoginDto) {
    return this.usersService.googleLogin(dto);
  }

  @Get('google-config')
  @Public()
  googleConfig() {
    return {
      success: true,
      data: { clientId: process.env.GOOGLE_CLIENT_ID },
    };
  }

  @Post('forgot-password')
  @Public()
  async forgotPassword(@Body() dto: ForgotPasswordDto) {
    return {
      success: true,
      data: await this.usersService.forgotPassword(dto),
    };
  }

  @Post('verify-otp')
  @Public()
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return {
      success: true,
      data: await this.usersService.verifyOtp(dto),
    };
  }

  @Post('reset-password')
  @Public()
  async resetPassword(@Body() dto: ResetPasswordDto) {
    return {
      success: true,
      data: await this.usersService.resetForgottenPassword(dto),
    };
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getMe(@CurrentUser() user: any) {
    return {
      success: true,
      data: await this.usersService.findById(user._id.toString()),
    };
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  async updateMe(@CurrentUser() user: any, @Body() dto: UpdateProfileDto) {
    return {
      success: true,
      data: await this.usersService.updateProfile(user._id.toString(), dto),
    };
  }

  @Put('me/password')
  @UseGuards(JwtAuthGuard)
  async changePassword(
    @CurrentUser() user: any,
    @Body() dto: ChangePasswordDto,
  ) {
    return {
      success: true,
      data: await this.usersService.changePassword(user._id.toString(), dto),
    };
  }

  @Post('me/avatar')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('profilePicture', {
      dest: join(process.cwd(), 'uploads', 'profiles'),
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  async uploadAvatar(@CurrentUser() user: any, @UploadedFile() file: any) {
    if (!file) {
      return { success: false, message: 'Profile image is required' };
    }
    const profilePicture = `/users/avatar/${file.filename}`;
    return {
      success: true,
      data: await this.usersService.updateProfilePicture(
        user._id.toString(),
        profilePicture,
      ),
    };
  }

  @Get('me/preferences')
  @UseGuards(JwtAuthGuard)
  async preferences(@CurrentUser() user: any) {
    return {
      success: true,
      data: await this.usersService.getNotificationPreferences(
        user._id.toString(),
      ),
    };
  }

  @Put('me/preferences')
  @UseGuards(JwtAuthGuard)
  async updatePreferences(
    @CurrentUser() user: any,
    @Body() dto: NotificationPreferencesDto,
  ) {
    return {
      success: true,
      data: await this.usersService.updateNotificationPreferences(
        user._id.toString(),
        dto,
      ),
    };
  }

  @Get('avatar/:filename')
  @Public()
  getAvatar(@Param('filename') filename: string, @Res() response: Response) {
    return response.sendFile(filename, {
      root: join(process.cwd(), 'uploads', 'profiles'),
    });
  }

  @Get(':id')
  @Public()
  async findOne(@Param('id') id: string) {
    return { success: true, data: await this.usersService.findById(id) };
  }
}
