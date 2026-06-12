import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Workout, WorkoutDocument } from './schemas/workout.schema';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';

@Injectable()
export class WorkoutsService {
  constructor(@InjectModel(Workout.name) private workoutModel: Model<WorkoutDocument>) {}

  async create(dto: CreateWorkoutDto) {
    return this.workoutModel.create(dto);
  }

  async findAll(userId: string) {
    return this.workoutModel.find({ userId }).sort({ date: -1 });
  }

  async findById(id: string) {
    const workout = await this.workoutModel.findById(id);
    if (!workout) throw new NotFoundException('Workout not found');
    return workout;
  }

  async update(id: string, dto: UpdateWorkoutDto) {
    const updated = await this.workoutModel.findByIdAndUpdate(id, dto, { new: true });
    if (!updated) throw new NotFoundException('Workout not found');
    return updated;
  }

  async remove(id: string) {
    const deleted = await this.workoutModel.findByIdAndDelete(id);
    if (!deleted) throw new NotFoundException('Workout not found');
  }
}