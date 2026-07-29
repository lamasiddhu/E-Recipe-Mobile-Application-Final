import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  ForbiddenException,
  UseGuards,
  Query,
  Res,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import type { Response } from 'express';
import { basename, join } from 'path';
import { FileInterceptor } from '@nestjs/platform-express';
import { RecipesService } from './recipes.service';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { UpdateRecipeDto } from './dto/update-recipe.dto';
import { FindRecipesQueryDto } from './dto/find-recipes-query.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';
import { paginatedResponse } from '../common/utils/pagination.util';

@Controller('recipes')
@UseGuards(JwtAuthGuard)
export class RecipesController {
  constructor(private readonly recipesService: RecipesService) {}

  @Get()
  @Public()
  async findAll(@Query() query: FindRecipesQueryDto) {
    const { data, total } = await this.recipesService.findAll(query);
    return paginatedResponse(data, total, query.page, query.limit);
  }

  @Get('image/:filename')
  @Public()
  image(@Param('filename') filename: string, @Res() response: Response) {
    return response.sendFile(basename(filename), {
      root: join(process.cwd(), 'uploads'),
    });
  }

  @Get('admin/all')
  async findAllForAdmin(@CurrentUser() user: any) {
    if (user.role !== 'admin') {
      throw new ForbiddenException('Admin access required');
    }
    return {
      success: true,
      data: await this.recipesService.findAllForAdmin(),
    };
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseObjectIdPipe) id: string,
    @CurrentUser() user: any,
  ) {
    return {
      success: true,
      data: await this.recipesService.findById(id, user._id.toString()),
    };
  }

  @Post('image')
  @UseInterceptors(
    FileInterceptor('image', {
      dest: join(process.cwd(), 'uploads'),
      limits: { fileSize: 8 * 1024 * 1024 },
    }),
  )
  uploadImage(@CurrentUser() user: any, @UploadedFile() file: any) {
    if (user.role !== 'admin') {
      throw new ForbiddenException('Admin access required');
    }
    if (!file) return { success: false, message: 'Recipe image is required' };
    return { success: true, data: { image: file.filename } };
  }

  @Post()
  async create(@Body() dto: CreateRecipeDto, @CurrentUser() user: any) {
    if (user.role !== 'admin') throw new ForbiddenException('Admin access required');
    return {
      success: true,
      data: await this.recipesService.create(dto, user._id),
    };
  }

  @Put(':id')
  async update(
    @Param('id', ParseObjectIdPipe) id: string,
    @Body() dto: UpdateRecipeDto,
    @CurrentUser() user: any,
  ) {
    if (user.role !== 'admin') {
      throw new ForbiddenException('Admin access required');
    }
    return { success: true, data: await this.recipesService.update(id, dto) };
  }

  @Delete(':id')
  async remove(
    @Param('id', ParseObjectIdPipe) id: string,
    @CurrentUser() user: any,
  ) {
    if (user.role !== 'admin') throw new ForbiddenException('Admin access required');
    await this.recipesService.remove(id);
    return { success: true, message: 'Recipe deleted' };
  }
}
