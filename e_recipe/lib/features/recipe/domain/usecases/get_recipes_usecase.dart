import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/repositories/recipe_repository.dart';

class GetRecipesParams {
  final String? category;
  final String? search;
  final String? difficulty;
  final int? maxTime;
  final int page;
  final int limit;

  const GetRecipesParams({
    this.category,
    this.search,
    this.difficulty,
    this.maxTime,
    this.page = 1,
    this.limit = 10,
  });
}

class GetRecipesUseCase
    implements UsecaseWithParams<RecipeListResult, GetRecipesParams> {
  final IRecipeRepository _recipeRepository;

  GetRecipesUseCase(this._recipeRepository);

  @override
  Future<AppResult<RecipeListResult>> call(GetRecipesParams params) {
    return _recipeRepository.getRecipes(
      category: params.category,
      search: params.search,
      difficulty: params.difficulty,
      maxTime: params.maxTime,
      page: params.page,
      limit: params.limit,
    );
  }
}
