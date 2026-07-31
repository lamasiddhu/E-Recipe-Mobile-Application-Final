import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:e_recipe/features/purchase/domain/usecases/purchase_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockPurchaseRepository extends Mock implements IPurchaseRepository {}

void main() {
  late MockPurchaseRepository purchases;

  setUpAll(() => registerFallbackValue(testRecipe));
  setUp(() => purchases = MockPurchaseRepository());

  test('purchase uses database recipe price and eSewa number', () async {
    when(
      () => purchases.purchase(
        testRecipe,
        price: testRecipe.price,
        esewaNumber: '9800000000',
      ),
    ).thenAnswer((_) async => ResultSuccess(testOrder));

    final result = await PurchaseRecipeUseCase(purchases)(
      testRecipe,
      esewaNumber: '9800000000',
    );

    expect(result, isA<ResultSuccess<PurchaseOrderEntity>>());
    verify(
      () =>
          purchases.purchase(testRecipe, price: 250, esewaNumber: '9800000000'),
    ).called(1);
  });
}
