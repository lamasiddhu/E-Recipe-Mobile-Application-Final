import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

enum RecipeListStatus { initial, loading, loaded, error }

class RecipeListState {
  final RecipeListStatus status;
  final List<RecipeEntity> recipes;
  final String category;
  final String search;
  final String? difficulty;
  final String? message;

  const RecipeListState({
    this.status = RecipeListStatus.initial,
    this.recipes = const [],
    this.category = 'All',
    this.search = '',
    this.difficulty,
    this.message,
  });

  RecipeListState copyWith({
    RecipeListStatus? status,
    List<RecipeEntity>? recipes,
    String? category,
    String? search,
    String? difficulty,
    String? message,
    bool clearMessage = false,
    bool clearDifficulty = false,
  }) {
    return RecipeListState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      category: category ?? this.category,
      search: search ?? this.search,
      difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
