import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

final recipeDetailViewModelProvider =
    NotifierProvider<RecipeDetailViewModel, RecipeDetailState>(
      RecipeDetailViewModel.new,
    );

class RecipeDetailViewModel extends Notifier<RecipeDetailState> {
  late final GetRecipeByIdUseCase _getRecipeByIdUseCase;

  @override
  RecipeDetailState build() {
    _getRecipeByIdUseCase = ref.read(getRecipeByIdUseCaseProvider);
    return const RecipeDetailState();
  }

  Future<void> loadRecipe(String id) async {
    state = state.copyWith(status: RecipeDetailStatus.loading);

    final result = await _getRecipeByIdUseCase(GetRecipeByIdParams(id));

    result.fold(
      (failure) => state = state.copyWith(
        status: RecipeDetailStatus.error,
        message: failure.message,
      ),
      (recipe) => state = state.copyWith(
        status: RecipeDetailStatus.loaded,
        recipe: recipe,
      ),
    );
  }
}
