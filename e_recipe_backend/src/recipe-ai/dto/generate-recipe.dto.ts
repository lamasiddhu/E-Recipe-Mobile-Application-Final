import {
  ArrayMaxSize,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class RecipeChatMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(300)
  text!: string;

  @IsString()
  role!: 'user' | 'assistant';
}

export class GenerateRecipeDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(300)
  query!: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => RecipeChatMessageDto)
  history?: RecipeChatMessageDto[];
}
