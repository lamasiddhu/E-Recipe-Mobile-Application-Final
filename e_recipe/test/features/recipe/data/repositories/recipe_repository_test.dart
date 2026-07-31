import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/recipe/data/datasources/remote/recipe_remote_datasource.dart';
import 'package:e_recipe/features/recipe/data/models/recipe_model.dart';
import 'package:e_recipe/features/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockRecipeDatasource extends Mock implements IRecipeDatasource {}

void main() {
  test('RecipeRepository maps paginated models to domain entities', () async {
    final datasource = MockRecipeDatasource();
    final repository = RecipeRepositoryImpl(datasource);
    final model = RecipeModel(
      id: testRecipe.id,
      title: testRecipe.title,
      description: testRecipe.description,
      ingredients: testRecipe.ingredients,
      instructions: testRecipe.instructions,
      category: testRecipe.category,
      totalTime: testRecipe.totalTime,
      difficulty: testRecipe.difficulty,
      image: testRecipe.image,
      price: testRecipe.price,
      badge: testRecipe.badge,
      createdBy: testRecipe.createdBy,
      createdAt: testRecipe.createdAt,
      updatedAt: testRecipe.updatedAt,
    );
    when(
      () => datasource.getRecipes(
        category: null,
        search: null,
        difficulty: null,
        maxTime: null,
        page: 1,
        limit: 10,
      ),
    ).thenAnswer((_) async => (recipes: [model], total: 1, page: 1, pages: 1));

    final result = await repository.getRecipes();

    expect(result, isA<ResultSuccess<RecipeListResult>>());
    result.fold(
      (_) => fail('Expected success'),
      (page) => expect(page.recipes.single.title, 'Spicy Chicken Curry'),
    );
  });
}
