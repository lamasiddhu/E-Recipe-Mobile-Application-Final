import { Injectable, NotFoundException, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async register(dto: CreateUserDto) {
    const exists = await this.userModel.findOne({ email: dto.email });
    if (exists) throw new BadRequestException('Email already exists');
    const user = await this.userModel.create(dto);
    const res = user.toObject() as any;
    delete res.password;
    return res;
  }

  async login(dto: LoginUserDto) {
    const user = await this.userModel.findOne({ email: dto.email }).select('+password');
    if (!user || !(await user.matchPassword(dto.password))) throw new UnauthorizedException('Invalid credentials');
    const token = user.getSignedJwtToken();
    const res = user.toObject() as any;
    delete res.password;
    return { success: true, token, data: res };
  }

  async findById(id: string) {
    const user = await this.userModel.findById(id);
    if (!user) throw new NotFoundException('User not found');
    return user;
  }
}