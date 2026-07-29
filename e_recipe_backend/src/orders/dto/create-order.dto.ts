import { IsMongoId, IsNumber, IsString, Matches, Min } from 'class-validator';

export class CreateOrderDto {
  @IsMongoId()
  recipeId!: string;

  @IsString()
  @Matches(/^(97|98)\d{8}$/, {
    message: 'Enter a valid 10-digit eSewa mobile number',
  })
  esewaNumber!: string;

  @IsNumber()
  @Min(1)
  amount!: number;
}
