import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

enum RecipeDetailStatus { initial, loading, loaded, error }

class RecipeDetailState {
  final RecipeDetailStatus status;
  final RecipeEntity? recipe;
  final String? message;

  const RecipeDetailState({
    this.status = RecipeDetailStatus.initial,
    this.recipe,
    this.message,
  });

  RecipeDetailState copyWith({
    RecipeDetailStatus? status,
    RecipeEntity? recipe,
    String? message,
  }) {
    return RecipeDetailState(
      status: status ?? this.status,
      recipe: recipe ?? this.recipe,
      message: message ?? this.message,
    );
  }
}
