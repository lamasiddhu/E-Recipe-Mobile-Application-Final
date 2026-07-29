import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';
import 'package:e_recipe/features/recipe_ai/domain/repositories/recipe_ai_repository.dart';

class GenerateRecipeUseCase {
  final RecipeAiRepository _repository;

  GenerateRecipeUseCase(this._repository);

  Future<RecipeAiResponse> call(
    String query, {
    List<RecipeChatMessage> history = const [],
  }) {
    return _repository.generate(query, history: history);
  }
}
