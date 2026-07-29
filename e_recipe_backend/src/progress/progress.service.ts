import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Progress, ProgressDocument } from './schemas/progress.schema';
import { CreateProgressDto } from './dto/create-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto';

@Injectable()
export class ProgressService {
  constructor(@InjectModel(Progress.name) private progressModel: Model<ProgressDocument>) {}

  async create(dto: CreateProgressDto) {
    return this.progressModel.create(dto);
  }

  async findAll(userId: string) {
    return this.progressModel.find({ userId }).sort({ date: -1 });
  }

  async findById(id: string) {
    const progress = await this.progressModel.findById(id);
    if (!progress) throw new NotFoundException('Progress not found');
    return progress;
  }

  async update(id: string, dto: UpdateProgressDto) {
    const updated = await this.progressModel.findByIdAndUpdate(id, dto, { new: true });
    if (!updated) throw new NotFoundException('Progress not found');
    return updated;
  }

  async remove(id: string) {
    const deleted = await this.progressModel.findByIdAndDelete(id);
    if (!deleted) throw new NotFoundException('Progress not found');
  }
}