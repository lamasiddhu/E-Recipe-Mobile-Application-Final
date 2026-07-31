import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:e_recipe/features/recipe/presentation/pages/discover_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  setUpAll(() => registerFallbackValue(const GetRecipesParams()));

  ProviderContainer buildContainer() {
    final getRecipes = MockGetRecipesUseCase();
    when(() => getRecipes(any())).thenAnswer(
      (_) async => ResultSuccess(
        RecipeListResult(recipes: [testRecipe], total: 1, page: 1, pages: 1),
      ),
    );
    final savedUseCases = MockSavedRecipeUseCases();
    when(savedUseCases.getSavedIds).thenReturn(const {});
    final container = ProviderContainer(
      overrides: [
        getRecipesUseCaseProvider.overrideWithValue(getRecipes),
        savedRecipeUseCasesProvider.overrideWithValue(savedUseCases),
      ],
    );
    return container;
  }

  testWidgets('loads and renders a recipe card', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverTab())),
      ),
    );
    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text(testRecipe.title), findsOneWidget);
    expect(find.text('NPR ${testRecipe.price}'), findsOneWidget);
  });

  testWidgets('shows all category chips', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverTab())),
      ),
    );
    await tester.pump();

    for (final category in ['All', 'Breakfast', 'Lunch', 'Dinner']) {
      expect(find.widgetWithText(ChoiceChip, category), findsOneWidget);
    }
  });

  testWidgets('tapping the bookmark toggle saves the recipe', (tester) async {
    final getRecipes = MockGetRecipesUseCase();
    when(() => getRecipes(any())).thenAnswer(
      (_) async => ResultSuccess(
        RecipeListResult(recipes: [testRecipe], total: 1, page: 1, pages: 1),
      ),
    );
    final savedUseCases = MockSavedRecipeUseCases();
    when(savedUseCases.getSavedIds).thenReturn(const {});
    when(() => savedUseCases.saveIds(any())).thenAnswer((_) async {});
    final container = ProviderContainer(
      overrides: [
        getRecipesUseCaseProvider.overrideWithValue(getRecipes),
        savedRecipeUseCasesProvider.overrideWithValue(savedUseCases),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverTab())),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();

    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    verify(() => savedUseCases.saveIds({testRecipe.id})).called(1);
  });
}
