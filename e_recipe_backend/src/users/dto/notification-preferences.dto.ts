import { IsBoolean, IsOptional } from 'class-validator';

export class NotificationPreferencesDto {
  @IsOptional()
  @IsBoolean()
  recipeUpdatesEnabled?: boolean;

  @IsOptional()
  @IsBoolean()
  proOffersEnabled?: boolean;
}
