import 'package:e_recipe/features/favorites/presentation/state/saved_recipes_state.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/favorites/domain/usecases/saved_recipe_usecases.dart';

final savedRecipesViewModelProvider =
    NotifierProvider<SavedRecipesViewModel, SavedRecipesState>(
      SavedRecipesViewModel.new,
    );

class SavedRecipesViewModel extends Notifier<SavedRecipesState> {
  late final GetRecipeByIdUseCase _getRecipeById;
  late final SavedRecipeUseCases _savedRecipeUseCases;

  @override
  SavedRecipesState build() {
    _getRecipeById = ref.read(getRecipeByIdUseCaseProvider);
    _savedRecipeUseCases = ref.read(savedRecipeUseCasesProvider);
    final ids = _savedRecipeUseCases.getSavedIds();
    return SavedRecipesState(recipeIds: ids);
  }

  bool isSaved(String recipeId) => state.recipeIds.contains(recipeId);

  Future<void> loadSavedRecipes() async {
    if (state.recipeIds.isEmpty) {
      state = state.copyWith(recipes: const [], clearMessage: true);
      return;
    }

    state = state.copyWith(loading: true, clearMessage: true);
    final recipes = <RecipeEntity>[];
    String? errorMessage;

    for (final id in state.recipeIds) {
      final result = await _getRecipeById(GetRecipeByIdParams(id));
      result.fold((failure) => errorMessage ??= failure.message, recipes.add);
    }

    state = state.copyWith(
      loading: false,
      recipes: recipes,
      message: errorMessage,
    );
  }

  Future<void> toggle(RecipeEntity recipe) async {
    final ids = {...state.recipeIds};
    final recipes = [...state.recipes];

    if (ids.remove(recipe.id)) {
      recipes.removeWhere((item) => item.id == recipe.id);
    } else {
      ids.add(recipe.id);
      if (!recipes.any((item) => item.id == recipe.id)) {
        recipes.add(recipe);
      }
    }

    await _savedRecipeUseCases.saveIds(ids);
    state = state.copyWith(
      recipeIds: ids,
      recipes: recipes,
      clearMessage: true,
    );
  }
}
