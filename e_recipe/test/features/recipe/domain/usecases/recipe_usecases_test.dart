import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockRecipeRepository extends Mock implements IRecipeRepository {}

void main() {
  late MockRecipeRepository recipes;

  setUpAll(() => registerFallbackValue(testRecipe));
  setUp(() => recipes = MockRecipeRepository());

  test('recipe list use case forwards all filters', () async {
    final page = RecipeListResult(
      recipes: [testRecipe],
      total: 1,
      page: 1,
      pages: 1,
    );
    when(
      () => recipes.getRecipes(
        category: 'Dinner',
        search: 'spicy',
        difficulty: 'Medium',
        maxTime: 40,
        page: 1,
        limit: 10,
      ),
    ).thenAnswer((_) async => ResultSuccess(page));

    final result = await GetRecipesUseCase(recipes)(
      const GetRecipesParams(
        category: 'Dinner',
        search: 'spicy',
        difficulty: 'Medium',
        maxTime: 40,
      ),
    );

    expect(result, isA<ResultSuccess<RecipeListResult>>());
    verify(
      () => recipes.getRecipes(
        category: 'Dinner',
        search: 'spicy',
        difficulty: 'Medium',
        maxTime: 40,
        page: 1,
        limit: 10,
      ),
    ).called(1);
  });

  test('recipe detail use case requests the selected ID', () async {
    when(
      () => recipes.getRecipeById(testRecipe.id),
    ).thenAnswer((_) async => ResultSuccess(testRecipe));

    final result = await GetRecipeByIdUseCase(recipes)(
      GetRecipeByIdParams(testRecipe.id),
    );

    expect(result, isA<ResultSuccess>());
    verify(() => recipes.getRecipeById(testRecipe.id)).called(1);
  });
}
