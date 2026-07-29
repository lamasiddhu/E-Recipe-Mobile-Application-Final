import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

final recipeListViewModelProvider =
    NotifierProvider<RecipeListViewModel, RecipeListState>(
      RecipeListViewModel.new,
    );

final discoverRecipeListViewModelProvider =
    NotifierProvider<RecipeListViewModel, RecipeListState>(
      RecipeListViewModel.new,
    );

class RecipeListViewModel extends Notifier<RecipeListState> {
  late final GetRecipesUseCase _getRecipesUseCase;

  @override
  RecipeListState build() {
    _getRecipesUseCase = ref.read(getRecipesUseCaseProvider);
    return const RecipeListState();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(
      status: RecipeListStatus.loading,
      clearMessage: true,
    );

    final result = await _getRecipesUseCase(
      GetRecipesParams(
        category: state.category == 'All' ? null : state.category,
        search: state.search.isEmpty ? null : state.search,
        difficulty: state.difficulty,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RecipeListStatus.error,
        message: failure.message,
      ),
      (result) => state = state.copyWith(
        status: RecipeListStatus.loaded,
        recipes: result.recipes,
      ),
    );
  }

  Future<void> setCategory(String category) async {
    state = state.copyWith(category: category);
    await loadRecipes();
  }

  Future<void> setSearch(String search) async {
    state = state.copyWith(search: search);
    await loadRecipes();
  }

  Future<void> setDifficulty(String? difficulty) async {
    state = state.copyWith(
      difficulty: difficulty,
      clearDifficulty: difficulty == null,
    );
    await loadRecipes();
  }
}
