import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('RecipePrice', () {
    test('price uses the stored database value', () {
      expect(RecipePrice.forRecipe(testRecipe), 250);
    });
    test('free recipe can have zero price', () {
      final free = _recipe(price: 0, badge: 'Free');
      expect(RecipePrice.forRecipe(free), 0);
    });
  });
}

RecipeEntity _recipe({required int price, required String badge}) {
  return RecipeEntity(
    id: 'id-$badge',
    title: badge,
    description: '',
    ingredients: const [],
    instructions: const [],
    category: 'Dinner',
    totalTime: 10,
    difficulty: 'Easy',
    image: '',
    price: price,
    badge: badge,
    createdBy: 'admin',
    createdAt: testDate,
    updatedAt: testDate,
  );
}
