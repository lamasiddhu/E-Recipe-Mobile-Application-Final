import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:e_recipe/features/purchase/domain/usecases/purchase_usecases.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockRecipeRepository extends Mock implements IRecipeRepository {}

class MockPurchaseRepository extends Mock implements IPurchaseRepository {}

void main() {
  late MockRecipeRepository recipes;
  late MockPurchaseRepository purchases;

  setUpAll(() => registerFallbackValue(testRecipe));
  setUp(() {
    recipes = MockRecipeRepository();
    purchases = MockPurchaseRepository();
  });

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

  test('purchase uses database recipe price and eSewa number', () async {
    when(
      () => purchases.purchase(
        testRecipe,
        price: testRecipe.price,
        esewaNumber: '9800000000',
      ),
    ).thenAnswer((_) async => ResultSuccess(testOrder));

    final result = await PurchaseRecipeUseCase(purchases)(
      testRecipe,
      esewaNumber: '9800000000',
    );

    expect(result, isA<ResultSuccess<PurchaseOrderEntity>>());
    verify(
      () =>
          purchases.purchase(testRecipe, price: 250, esewaNumber: '9800000000'),
    ).called(1);
  });
}
