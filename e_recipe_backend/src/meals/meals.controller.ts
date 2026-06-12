import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Query } from '@nestjs/common';
import { MealsService } from './meals.service';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';

@Controller('meals')
@UseGuards(JwtAuthGuard)
export class MealsController {
  constructor(private readonly mealsService: MealsService) {}
  @Post() async create(@Body() dto: CreateMealDto) { return { success: true, data: await this.mealsService.create(dto) }; }
  @Get() async findAll(@CurrentUser() user: any, @Query('userId') userId?: string) { return { success: true, data: await this.mealsService.findAll(userId || user._id.toString()) }; }
  @Get(':id') async findOne(@Param('id', ParseObjectIdPipe) id: string) { return { success: true, data: await this.mealsService.findById(id) }; }
  @Put(':id') async update(@Param('id', ParseObjectIdPipe) id: string, @Body() dto: UpdateMealDto) { return { success: true, data: await this.mealsService.update(id, dto) }; }
  @Delete(':id') async remove(@Param('id', ParseObjectIdPipe) id: string) { return { success: true, data: await this.mealsService.remove(id) }; }
}