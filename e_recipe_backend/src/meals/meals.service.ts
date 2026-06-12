import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Meal, MealDocument } from './schemas/meal.schema';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';

@Injectable()
export class MealsService {
  constructor(@InjectModel(Meal.name) private mealModel: Model<MealDocument>) {}
  async create(dto: CreateMealDto) { return this.mealModel.create(dto); }
  async findAll(userId: string) { return this.mealModel.find({ userId }).sort({ eatenAt: -1 }); }
  async findById(id: string) { const meal = await this.mealModel.findById(id); if (!meal) throw new NotFoundException('Meal not found'); return meal; }
  async update(id: string, dto: UpdateMealDto) { const updated = await this.mealModel.findByIdAndUpdate(id, dto, { new: true }); if (!updated) throw new NotFoundException('Meal not found'); return updated; }
  async remove(id: string) { const deleted = await this.mealModel.findByIdAndDelete(id); if (!deleted) throw new NotFoundException('Meal not found'); return deleted; }
}