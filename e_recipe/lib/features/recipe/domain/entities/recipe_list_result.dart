import 'recipe_entity.dart';

class RecipeListResult {
  final List<RecipeEntity> recipes;
  final int total;
  final int page;
  final int pages;

  const RecipeListResult({
    required this.recipes,
    required this.total,
    required this.page,
    required this.pages,
  });
}
