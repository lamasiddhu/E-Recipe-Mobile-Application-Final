import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:e_recipe/features/recipe/presentation/pages/recipe_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  setUpAll(() => registerFallbackValue(const GetRecipesParams()));

  testWidgets('renders recipe cards once the list loads', (tester) async {
    final getRecipes = MockGetRecipesUseCase();
    when(() => getRecipes(any())).thenAnswer(
      (_) async => ResultSuccess(
        RecipeListResult(recipes: [testRecipe], total: 1, page: 1, pages: 1),
      ),
    );
    final container = ProviderContainer(
      overrides: [getRecipesUseCaseProvider.overrideWithValue(getRecipes)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RecipeListView()),
      ),
    );
    await tester.pump();

    expect(find.text('All Recipes'), findsOneWidget);
    expect(find.text(testRecipe.title), findsOneWidget);
    expect(
      find.text('${testRecipe.totalTime} min • ${testRecipe.difficulty}'),
      findsOneWidget,
    );
  });

  testWidgets('shows an empty-state message when there are no recipes', (
    tester,
  ) async {
    final getRecipes = MockGetRecipesUseCase();
    when(() => getRecipes(any())).thenAnswer(
      (_) async =>
          const ResultSuccess(RecipeListResult(recipes: [], total: 0, page: 1, pages: 0)),
    );
    final container = ProviderContainer(
      overrides: [getRecipesUseCaseProvider.overrideWithValue(getRecipes)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RecipeListView()),
      ),
    );
    await tester.pump();

    expect(find.text('No recipes found.'), findsOneWidget);
  });
}
