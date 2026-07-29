import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/domain/repositories/recipe_repository.dart';

class GetRecipeByIdParams {
  final String id;

  const GetRecipeByIdParams(this.id);
}

class GetRecipeByIdUseCase
    implements UsecaseWithParams<RecipeEntity, GetRecipeByIdParams> {
  final IRecipeRepository _recipeRepository;

  GetRecipeByIdUseCase(this._recipeRepository);

  @override
  Future<AppResult<RecipeEntity>> call(GetRecipeByIdParams params) {
    return _recipeRepository.getRecipeById(params.id);
  }
}
