import {
  IsString,
  IsNotEmpty,
  IsArray,
  ArrayNotEmpty,
  IsIn,
  IsNumber,
  IsOptional,
} from 'class-validator';
import { RECIPE_CATEGORIES } from '../constants/recipe-categories.constant';

export class CreateRecipeDto {
  @IsString()
  @IsNotEmpty()
  title!: string;

  @IsString()
  @IsNotEmpty()
  description!: string;

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  ingredients!: string[];

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  instructions!: string[];

  @IsIn(RECIPE_CATEGORIES)
  category!: string;

  @IsOptional()
  @IsNumber()
  prepTime?: number;

  @IsOptional()
  @IsNumber()
  cookTime?: number;

  @IsNumber()
  totalTime!: number;

  @IsIn(['Easy', 'Medium', 'Hard'])
  difficulty!: string;

  @IsOptional()
  @IsString()
  image?: string;

  @IsOptional()
  @IsString()
  videoUrl?: string;

  @IsOptional()
  @IsNumber()
  price?: number;

  @IsOptional()
  @IsIn(['Free', 'Normal', 'Pro'])
  badge?: string;
}
