import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_list_result.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:e_recipe/features/recipe/presentation/view_model/recipe_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockGetRecipesUseCase extends Mock implements GetRecipesUseCase {}

void main() {
  setUpAll(() => registerFallbackValue(const GetRecipesParams()));

  test(
    'search and difficulty filters flow through Riverpod to the use case',
    () async {
      final useCase = MockGetRecipesUseCase();
      final result = RecipeListResult(
        recipes: [testRecipe],
        total: 1,
        page: 1,
        pages: 1,
      );
      when(() => useCase(any())).thenAnswer((_) async => ResultSuccess(result));

      final container = ProviderContainer(
        overrides: [getRecipesUseCaseProvider.overrideWithValue(useCase)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        discoverRecipeListViewModelProvider.notifier,
      );
      await notifier.setSearch('spicy');
      await notifier.setDifficulty('Medium');

      final state = container.read(discoverRecipeListViewModelProvider);
      expect(state.status, RecipeListStatus.loaded);
      expect(state.search, 'spicy');
      expect(state.difficulty, 'Medium');
      expect(state.recipes.single.id, testRecipe.id);

      final calls = verify(() => useCase(captureAny())).captured;
      expect(calls, hasLength(2));
      final finalParams = calls.last as GetRecipesParams;
      expect(finalParams.search, 'spicy');
      expect(finalParams.difficulty, 'Medium');
    },
  );
}
