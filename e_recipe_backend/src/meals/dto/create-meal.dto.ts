import { IsString, IsNotEmpty, IsNumber, IsMongoId } from 'class-validator';

export class CreateMealDto {
  @IsString() @IsNotEmpty() mealName!: string;
  @IsNumber() calories!: number;
  @IsNumber() protein!: number;
  @IsNumber() carbs!: number;
  @IsNumber() fats!: number;
  @IsMongoId() userId!: string;
}