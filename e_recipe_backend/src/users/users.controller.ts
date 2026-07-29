import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register') @Public()
  async register(@Body() dto: CreateUserDto) {
    return { success: true, data: await this.usersService.register(dto) };
  }

  @Post('login') @Public()
  async login(@Body() dto: LoginUserDto) {
    return this.usersService.login(dto);
  }

  @Get('me') @UseGuards(JwtAuthGuard)
  async getMe(@CurrentUser() user: any) {
    return { success: true, data: await this.usersService.findById(user._id.toString()) };
  }

  @Get(':id') @Public()
  async findOne(@Param('id') id: string) {
    return { success: true, data: await this.usersService.findById(id) };
  }
}