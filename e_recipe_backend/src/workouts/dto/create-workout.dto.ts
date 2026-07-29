import { IsString, IsNotEmpty, IsNumber, IsOptional, IsMongoId } from 'class-validator';

export class CreateWorkoutDto {
  @IsMongoId()
  userId!: string;
  
  @IsString() @IsNotEmpty() 
  exerciseName!: string;
  
  @IsNumber() 
  sets!: number;
  
  @IsNumber() 
  reps!: number;
  
  @IsNumber() @IsOptional() 
  weight?: number;
}