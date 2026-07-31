import 'package:e_recipe/features/purchase/presentation/state/purchase_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('PurchaseState', () {
    test('defaults to not processing', () {
      expect(const PurchaseState().processing, isFalse);
    });
    test('returns purchased recipe IDs', () {
      expect(PurchaseState(orders: [testOrder]).purchasedRecipeIds, {
        testRecipe.id,
      });
    });
  });
}
