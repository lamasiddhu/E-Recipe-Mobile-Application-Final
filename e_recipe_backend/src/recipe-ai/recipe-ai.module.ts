import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Recipe, RecipeSchema } from '../recipes/schemas/recipe.schema';
import { RecipesModule } from '../recipes/recipes.module';
import { RecipeAiController } from './recipe-ai.controller';
import { RecipeAiService } from './recipe-ai.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Recipe.name, schema: RecipeSchema }]),
    RecipesModule,
  ],
  controllers: [RecipeAiController],
  providers: [RecipeAiService],
})
export class RecipeAiModule {}
