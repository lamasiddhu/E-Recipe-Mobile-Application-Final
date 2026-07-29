import { IsNumber, IsOptional, IsMongoId } from 'class-validator';

export class CreateProgressDto {
  @IsMongoId()
  userId!: string;
  
  @IsNumber() 
  weight!: number;
  
  @IsNumber() @IsOptional() 
  bodyFat?: number;
  
  @IsNumber() @IsOptional() 
  muscleMass?: number;
}