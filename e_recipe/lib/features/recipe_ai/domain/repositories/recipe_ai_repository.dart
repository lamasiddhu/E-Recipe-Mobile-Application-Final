import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';

abstract interface class RecipeAiRepository {
  Future<RecipeAiResponse> generate(
    String query, {
    List<RecipeChatMessage> history,
  });
}
