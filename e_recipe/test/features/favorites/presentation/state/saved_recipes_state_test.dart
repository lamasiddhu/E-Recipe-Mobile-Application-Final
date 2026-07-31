import 'package:e_recipe/features/favorites/presentation/state/saved_recipes_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('SavedRecipesState', () {
    test('defaults to no saved IDs', () {
      expect(const SavedRecipesState().recipeIds, isEmpty);
    });
    test('copy stores loaded recipes', () {
      expect(
        const SavedRecipesState().copyWith(recipes: [testRecipe]).recipes,
        hasLength(1),
      );
    });
  });
}
