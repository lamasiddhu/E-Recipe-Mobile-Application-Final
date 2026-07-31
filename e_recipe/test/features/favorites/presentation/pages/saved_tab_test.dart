import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/favorites/presentation/pages/saved_tab.dart';
import 'package:e_recipe/features/favorites/presentation/view_model/saved_recipes_viewmodel.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  setUpAll(() => registerFallbackValue(GetRecipeByIdParams(testRecipe.id)));

  testWidgets('shows an empty state when nothing is saved', (tester) async {
    final savedUseCases = MockSavedRecipeUseCases();
    when(savedUseCases.getSavedIds).thenReturn(const {});
    final container = ProviderContainer(
      overrides: [savedRecipeUseCasesProvider.overrideWithValue(savedUseCases)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SavedTab())),
      ),
    );

    expect(find.text('No saved recipes yet'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('renders saved recipes once they load', (tester) async {
    final savedUseCases = MockSavedRecipeUseCases();
    when(savedUseCases.getSavedIds).thenReturn({testRecipe.id});
    final getRecipeById = MockGetRecipeByIdUseCase();
    when(
      () => getRecipeById(any()),
    ).thenAnswer((_) async => ResultSuccess(testRecipe));
    final container = ProviderContainer(
      overrides: [
        savedRecipeUseCasesProvider.overrideWithValue(savedUseCases),
        getRecipeByIdUseCaseProvider.overrideWithValue(getRecipeById),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(savedRecipesViewModelProvider.notifier)
        .loadSavedRecipes();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SavedTab())),
      ),
    );

    expect(find.text(testRecipe.title), findsOneWidget);
    expect(
      find.text('${testRecipe.category} • ${testRecipe.totalTime} min'),
      findsOneWidget,
    );
    expect(find.text('No saved recipes yet'), findsNothing);
  });

  testWidgets('tapping the bookmark icon removes a saved recipe', (
    tester,
  ) async {
    final savedUseCases = MockSavedRecipeUseCases();
    when(savedUseCases.getSavedIds).thenReturn({testRecipe.id});
    when(() => savedUseCases.saveIds(any())).thenAnswer((_) async {});
    final getRecipeById = MockGetRecipeByIdUseCase();
    when(
      () => getRecipeById(any()),
    ).thenAnswer((_) async => ResultSuccess(testRecipe));
    final container = ProviderContainer(
      overrides: [
        savedRecipeUseCasesProvider.overrideWithValue(savedUseCases),
        getRecipeByIdUseCaseProvider.overrideWithValue(getRecipeById),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(savedRecipesViewModelProvider.notifier)
        .loadSavedRecipes();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SavedTab())),
      ),
    );

    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump();

    expect(find.text('No saved recipes yet'), findsOneWidget);
    verify(() => savedUseCases.saveIds(<String>{})).called(1);
  });
}
