import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Query } from '@nestjs/common';
import { WorkoutsService } from './workouts.service';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';

@Controller('workouts')
@UseGuards(JwtAuthGuard)
export class WorkoutsController {
  constructor(private readonly workoutsService: WorkoutsService) {}

  @Post()
  async create(@Body() dto: CreateWorkoutDto, @CurrentUser() user: any) {
    return { success: true, data: await this.workoutsService.create({ ...dto, userId: user._id }) };
  }

  @Get()
  async findAll(@CurrentUser() user: any) {
    return { success: true, data: await this.workoutsService.findAll(user._id.toString()) };
  }

  @Get(':id')
  async findOne(@Param('id', ParseObjectIdPipe) id: string) {
    return { success: true, data: await this.workoutsService.findById(id) };
  }

  @Put(':id')
  async update(@Param('id', ParseObjectIdPipe) id: string, @Body() dto: UpdateWorkoutDto) {
    return { success: true, data: await this.workoutsService.update(id, dto) };
  }

  @Delete(':id')
  async remove(@Param('id', ParseObjectIdPipe) id: string) {
    await this.workoutsService.remove(id);
    return { success: true, message: 'Workout deleted' };
  }
}