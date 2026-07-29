import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/recipe/data/datasources/remote/recipe_remote_datasource.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements IRecipeRepository {
  final IRecipeDatasource _recipeDatasource;

  RecipeRepositoryImpl(this._recipeDatasource);

  @override
  Future<AppResult<RecipeListResult>> getRecipes({
    String? category,
    String? search,
    String? difficulty,
    int? maxTime,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await _recipeDatasource.getRecipes(
        category: category,
        search: search,
        difficulty: difficulty,
        maxTime: maxTime,
        page: page,
        limit: limit,
      );
      return ResultSuccess(
        RecipeListResult(
          recipes: result.recipes.map((model) => model.toEntity()).toList(),
          total: result.total,
          page: result.page,
          pages: result.pages,
        ),
      );
    } on ApiException catch (e) {
      return ResultFailure(
        ApiFailure(statusCode: e.statusCode, message: e.message),
      );
    } catch (error) {
      return const ResultFailure(
        ApiFailure(message: 'Unexpected error occurred.'),
      );
    }
  }

  @override
  Future<AppResult<RecipeEntity>> getRecipeById(String id) async {
    try {
      final model = await _recipeDatasource.getRecipeById(id);
      return ResultSuccess(model.toEntity());
    } on ApiException catch (e) {
      return ResultFailure(
        ApiFailure(statusCode: e.statusCode, message: e.message),
      );
    } catch (error) {
      return const ResultFailure(
        ApiFailure(message: 'Unexpected error occurred.'),
      );
    }
  }
}
