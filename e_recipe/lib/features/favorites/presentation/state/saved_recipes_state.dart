import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

class SavedRecipesState {
  final bool loading;
  final Set<String> recipeIds;
  final List<RecipeEntity> recipes;
  final String? message;

  const SavedRecipesState({
    this.loading = false,
    this.recipeIds = const {},
    this.recipes = const [],
    this.message,
  });

  SavedRecipesState copyWith({
    bool? loading,
    Set<String>? recipeIds,
    List<RecipeEntity>? recipes,
    String? message,
    bool clearMessage = false,
  }) {
    return SavedRecipesState(
      loading: loading ?? this.loading,
      recipeIds: recipeIds ?? this.recipeIds,
      recipes: recipes ?? this.recipes,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
