import {
  Injectable,
  NotFoundException,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Connection } from 'mongoose';
import { InjectConnection } from '@nestjs/mongoose';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';
import * as nodemailer from 'nodemailer';
import * as bcrypt from 'bcryptjs';
import { randomBytes, randomInt } from 'crypto';
import { User, UserDocument } from './schemas/user.schema';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { NotificationPreferencesDto } from './dto/notification-preferences.dto';
import {
  PasswordReset,
  PasswordResetDocument,
} from './schemas/password-reset.schema';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { GoogleLoginDto } from './dto/google-login.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(PasswordReset.name)
    private passwordResetModel: Model<PasswordResetDocument>,
    @InjectConnection() private connection: Connection,
    private config: ConfigService,
  ) {}

  async register(dto: CreateUserDto) {
    const exists = await this.userModel.findOne({ email: dto.email });
    if (exists) throw new BadRequestException('Email already exists');
    const user = await this.userModel.create({
      ...dto,
      fullName: `${dto.firstName} ${dto.lastName}`.trim(),
      recipeUpdatesEnabledAt: new Date(),
      proOffersEnabledAt: new Date(),
    });
    const res = user.toObject() as any;
    delete res.password;
    const now = new Date();
    await this.connection.collection('notifications').insertOne({
      userId: user._id,
      broadcast: false,
      message:
        'Welcome to E-Recipe! We hope E-Recipe makes your life easier by helping you cook elegant food at home.',
      type: 'welcome',
      action: 'discover_recipes',
      read: false,
      createdAt: now,
      updatedAt: now,
    });
    return this.toApiUser(res);
  }

  async login(dto: LoginUserDto) {
    const user = await this.userModel
      .findOne({ email: dto.email })
      .select('+password');
    if (!user || !(await user.matchPassword(dto.password)))
      throw new UnauthorizedException('Invalid credentials');
    const token = user.getSignedJwtToken();
    const res = user.toObject() as any;
    delete res.password;
    return { success: true, token, data: this.toApiUser(res) };
  }

  async googleLogin(dto: GoogleLoginDto) {
    const clientId = this.config.get<string>('GOOGLE_CLIENT_ID');
    if (!clientId) throw new UnauthorizedException('Google login is not configured');
    const ticket = await new OAuth2Client(clientId).verifyIdToken({
      idToken: dto.idToken,
      audience: clientId,
    });
    const payload = ticket.getPayload();
    if (!payload?.sub || !payload.email || payload.email_verified !== true) {
      throw new UnauthorizedException('Google account could not be verified');
    }

    const email = payload.email.toLowerCase();
    let user = await this.userModel.findOne({
      $or: [{ googleId: payload.sub }, { email }],
    });
    if (!user) {
      const names = String(payload.name ?? '').trim().split(/\s+/);
      user = await this.userModel.create({
        firstName: payload.given_name ?? names[0] ?? 'Google',
        lastName:
          payload.family_name ??
          (names.length > 1 ? names.slice(1).join(' ') : 'User'),
        fullName: payload.name ?? email.split('@')[0],
        email,
        phone: 'Google account',
        password: randomBytes(32).toString('hex'),
        googleId: payload.sub,
        authProvider: 'google',
        profilePicture: payload.picture ?? 'default-profile.png',
        avatarUrl: payload.picture,
        recipeUpdatesEnabledAt: new Date(),
        proOffersEnabledAt: new Date(),
      });
      await this.createWelcomeNotification(user._id);
    } else if (!user.googleId) {
      user.googleId = payload.sub;
      user.authProvider = 'google';
      if (
        payload.picture &&
        (!user.profilePicture ||
          user.profilePicture === 'default-profile.png')
      ) {
        user.profilePicture = payload.picture;
        user.avatarUrl = payload.picture;
      }
      await user.save();
    }

    const token = user.getSignedJwtToken();
    return {
      success: true,
      token,
      data: this.toApiUser(user.toObject()),
    };
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const email = dto.email.toLowerCase();
    const user = await this.userModel.findOne({ email }).lean();
    const generic = {
      message: 'If this email is registered, a verification code was sent.',
    };
    if (!user) return generic;

    const existing = await this.passwordResetModel
      .findOne({ email })
      .select('+otpHash +resetTokenHash');
    if (
      existing?.lastSentAt &&
      Date.now() - existing.lastSentAt.getTime() < 60_000
    ) {
      return generic;
    }

    const otp = randomInt(100000, 1000000).toString();
    const otpHash = await bcrypt.hash(otp, 10);
    const minutes = Number(this.config.get('OTP_EXPIRE_MINUTES') ?? 10);
    const now = new Date();
    await this.passwordResetModel.findOneAndUpdate(
      { email },
      {
        email,
        otpHash,
        expiresAt: new Date(now.getTime() + minutes * 60_000),
        attempts: 0,
        lastSentAt: now,
        $unset: { resetTokenHash: 1, verifiedAt: 1 },
      },
      { upsert: true, new: true },
    );

    await this.sendOtpEmail(email, otp, minutes);
    return generic;
  }

  async verifyOtp(dto: VerifyOtpDto) {
    const email = dto.email.toLowerCase();
    const reset = await this.passwordResetModel
      .findOne({ email })
      .select('+otpHash +resetTokenHash');
    if (!reset || reset.expiresAt.getTime() <= Date.now()) {
      throw new BadRequestException('The verification code has expired');
    }
    if (reset.attempts >= 5) {
      throw new BadRequestException('Too many incorrect attempts');
    }
    if (!(await bcrypt.compare(dto.otp, reset.otpHash))) {
      reset.attempts += 1;
      await reset.save();
      throw new BadRequestException('Incorrect verification code');
    }

    const resetToken = randomBytes(32).toString('hex');
    reset.resetTokenHash = await bcrypt.hash(resetToken, 10);
    reset.verifiedAt = new Date();
    await reset.save();
    return { resetToken };
  }

  async resetForgottenPassword(dto: ResetPasswordDto) {
    const email = dto.email.toLowerCase();
    const reset = await this.passwordResetModel
      .findOne({ email })
      .select('+otpHash +resetTokenHash');
    if (
      !reset?.verifiedAt ||
      !reset.resetTokenHash ||
      reset.expiresAt.getTime() <= Date.now() ||
      !(await bcrypt.compare(dto.resetToken, reset.resetTokenHash))
    ) {
      throw new BadRequestException('Password reset session is invalid or expired');
    }
    const user = await this.userModel.findOne({ email }).select('+password');
    if (!user) throw new NotFoundException('User not found');
    user.password = dto.newPassword;
    await user.save();
    await this.passwordResetModel.deleteOne({ _id: reset._id });
    return { message: 'Password changed successfully' };
  }

  async findById(id: string) {
    const user = await this.userModel.findById(id);
    if (!user) throw new NotFoundException('User not found');
    return this.toApiUser(user.toObject());
  }

  async updateProfile(id: string, dto: UpdateProfileDto) {
    const update = {
      ...dto,
      fullName:
        dto.firstName || dto.lastName
          ? `${dto.firstName ?? ''} ${dto.lastName ?? ''}`.trim()
          : undefined,
    };
    const user = await this.userModel.findByIdAndUpdate(id, update, {
      new: true,
      runValidators: true,
    });
    if (!user) throw new NotFoundException('User not found');
    return this.toApiUser(user.toObject());
  }

  async updateProfilePicture(id: string, profilePicture: string) {
    const user = await this.userModel.findByIdAndUpdate(
      id,
      { profilePicture, avatarUrl: profilePicture },
      { new: true },
    );
    if (!user) throw new NotFoundException('User not found');
    return this.toApiUser(user.toObject());
  }

  async changePassword(id: string, dto: ChangePasswordDto) {
    const user = await this.userModel.findById(id).select('+password');
    if (!user) throw new NotFoundException('User not found');
    if (!(await user.matchPassword(dto.currentPassword))) {
      throw new BadRequestException('Current password is incorrect');
    }

    user.password = dto.newPassword;
    await user.save();
    return { message: 'Password changed successfully' };
  }

  async getNotificationPreferences(id: string) {
    const user = await this.userModel.findById(id).lean();
    if (!user) throw new NotFoundException('User not found');
    return {
      recipeUpdatesEnabled: user.recipeUpdatesEnabled !== false,
      proOffersEnabled: user.proOffersEnabled !== false,
    };
  }

  async updateNotificationPreferences(
    id: string,
    dto: NotificationPreferencesDto,
  ) {
    const current = await this.userModel.findById(id).lean();
    if (!current) throw new NotFoundException('User not found');
    const update: Record<string, unknown> = {};
    if (dto.recipeUpdatesEnabled != null) {
      update.recipeUpdatesEnabled = dto.recipeUpdatesEnabled;
      if (
        dto.recipeUpdatesEnabled &&
        current.recipeUpdatesEnabled === false
      ) {
        update.recipeUpdatesEnabledAt = new Date();
      }
    }
    if (dto.proOffersEnabled != null) {
      update.proOffersEnabled = dto.proOffersEnabled;
      if (dto.proOffersEnabled && current.proOffersEnabled === false) {
        update.proOffersEnabledAt = new Date();
      }
    }
    const user = await this.userModel.findByIdAndUpdate(id, update, {
      new: true,
    });
    return {
      recipeUpdatesEnabled: user?.recipeUpdatesEnabled !== false,
      proOffersEnabled: user?.proOffersEnabled !== false,
    };
  }

  private toApiUser(user: Record<string, any>) {
    const nameParts = String(user.fullName ?? '')
      .trim()
      .split(/\s+/);
    return {
      ...user,
      firstName: user.firstName ?? nameParts[0] ?? '',
      lastName:
        user.lastName ??
        (nameParts.length > 1 ? nameParts.slice(1).join(' ') : ''),
      profilePicture:
        user.profilePicture ?? user.avatarUrl ?? 'default-profile.png',
      bio: user.bio ?? '',
      isPro: Boolean(user.isPro),
    };
  }

  private async createWelcomeNotification(userId: any) {
    const now = new Date();
    await this.connection.collection('notifications').insertOne({
      userId,
      broadcast: false,
      message:
        'Welcome to E-Recipe! We hope E-Recipe makes your life easier by helping you cook elegant food at home.',
      type: 'welcome',
      action: 'discover_recipes',
      read: false,
      createdAt: now,
      updatedAt: now,
    });
  }

  private async sendOtpEmail(email: string, otp: string, minutes: number) {
    const gmailUser = this.config.get<string>('GMAIL_USER');
    const gmailPassword = this.config
      .get<string>('GMAIL_APP_PASSWORD')
      ?.replace(/\s/g, '');
    if (!gmailUser || !gmailPassword) {
      throw new BadRequestException('Email OTP is not configured');
    }
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: { user: gmailUser, pass: gmailPassword },
    });
    await transporter.sendMail({
      from: `"E-Recipe" <${gmailUser}>`,
      to: email,
      subject: 'Your E-Recipe password reset code',
      text: `Your E-Recipe verification code is ${otp}. It expires in ${minutes} minutes.`,
      html: `<div style="font-family:Arial,sans-serif"><h2>E-Recipe password reset</h2><p>Your verification code is:</p><p style="font-size:32px;font-weight:bold;letter-spacing:8px">${otp}</p><p>This code expires in ${minutes} minutes. If you did not request it, ignore this email.</p></div>`,
    });
  }
}
