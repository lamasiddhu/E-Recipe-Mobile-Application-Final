import 'package:e_recipe/features/recipe_ai/data/datasources/recipe_ai_remote_datasource.dart';
import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';
import 'package:e_recipe/features/recipe_ai/domain/repositories/recipe_ai_repository.dart';

class RecipeAiRepositoryImpl implements RecipeAiRepository {
  final RecipeAiRemoteDatasource _datasource;

  RecipeAiRepositoryImpl(this._datasource);

  @override
  Future<RecipeAiResponse> generate(
    String query, {
    List<RecipeChatMessage> history = const [],
  }) {
    return _datasource.generate(query, history: history);
  }
}
