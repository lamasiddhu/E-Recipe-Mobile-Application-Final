import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('RecipeListState', () {
    test('defaults to All category', () {
      expect(const RecipeListState().category, 'All');
    });
    test('copy updates recipes', () {
      expect(
        const RecipeListState().copyWith(recipes: [testRecipe]).recipes,
        hasLength(1),
      );
    });
  });
}
