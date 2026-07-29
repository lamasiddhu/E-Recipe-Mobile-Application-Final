import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { GenerateRecipeDto } from './dto/generate-recipe.dto';
import { RecipeAiService } from './recipe-ai.service';

@Controller('recipe-ai')
@UseGuards(JwtAuthGuard)
export class RecipeAiController {
  constructor(private readonly service: RecipeAiService) {}

  @Post('generate')
  async generate(@Body() dto: GenerateRecipeDto) {
    return { success: true, data: await this.service.generate(dto) };
  }
}
