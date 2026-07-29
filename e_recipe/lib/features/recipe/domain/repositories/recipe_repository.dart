import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';

abstract interface class IRecipeRepository {
  Future<AppResult<RecipeListResult>> getRecipes({
    String? category,
    String? search,
    String? difficulty,
    int? maxTime,
    int page,
    int limit,
  });

  Future<AppResult<RecipeEntity>> getRecipeById(String id);
}
