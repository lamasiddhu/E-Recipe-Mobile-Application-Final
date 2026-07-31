import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/presentation/pages/purchased_tab.dart';
import 'package:e_recipe/features/purchase/presentation/view_model/purchase_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  testWidgets('shows an empty state when nothing has been purchased', (
    tester,
  ) async {
    final ordersUseCase = MockGetOrdersUseCase();
    when(ordersUseCase.call).thenAnswer((_) async => const ResultSuccess([]));
    final container = ProviderContainer(
      overrides: [getOrdersUseCaseProvider.overrideWithValue(ordersUseCase)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: PurchasedTab())),
      ),
    );

    expect(find.text('No purchased recipes'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });

  testWidgets('renders purchased recipe cards once orders load', (
    tester,
  ) async {
    final ordersUseCase = MockGetOrdersUseCase();
    when(
      ordersUseCase.call,
    ).thenAnswer((_) async => ResultSuccess([testOrder]));
    final container = ProviderContainer(
      overrides: [getOrdersUseCaseProvider.overrideWithValue(ordersUseCase)],
    );
    addTearDown(container.dispose);
    await container.read(purchaseViewModelProvider.notifier).loadOrders();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: PurchasedTab())),
      ),
    );

    expect(find.text(testOrder.recipe.title), findsOneWidget);
    expect(find.text('OWNED • NPR ${testOrder.price}'), findsOneWidget);
    expect(find.text('No purchased recipes'), findsNothing);
  });

  testWidgets('shows the page heading and subtitle', (tester) async {
    final ordersUseCase = MockGetOrdersUseCase();
    when(ordersUseCase.call).thenAnswer((_) async => const ResultSuccess([]));
    final container = ProviderContainer(
      overrides: [getOrdersUseCaseProvider.overrideWithValue(ordersUseCase)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: PurchasedTab())),
      ),
    );

    expect(find.text('Purchased'), findsOneWidget);
    expect(find.text('Recipes you own are kept here.'), findsOneWidget);
  });
}
