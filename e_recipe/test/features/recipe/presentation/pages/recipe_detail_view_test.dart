import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/presentation/state/purchase_state.dart';
import 'package:e_recipe/features/purchase/presentation/view_model/purchase_viewmodel.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:e_recipe/features/recipe/presentation/pages/recipe_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/fixtures.dart';

RecipeEntity _recipe({required String badge}) {
  return RecipeEntity(
    id: 'recipe-$badge',
    title: 'Test $badge Recipe',
    description: 'A test recipe.',
    ingredients: const ['Salt'],
    instructions: const ['Cook it'],
    category: 'Dinner',
    totalTime: 20,
    difficulty: 'Easy',
    image: '',
    price: badge == 'Free' ? 0 : 250,
    badge: badge,
    createdBy: 'admin',
    createdAt: testDate,
    updatedAt: testDate,
  );
}

void main() {
  setUpAll(() => registerFallbackValue(const GetRecipeByIdParams('')));

  ProviderContainer buildContainer(RecipeEntity recipe) {
    final getRecipeById = MockGetRecipeByIdUseCase();
    when(
      () => getRecipeById(any()),
    ).thenAnswer((_) async => ResultSuccess(recipe));
    final savedUseCases = MockSavedRecipeUseCases();
    when(savedUseCases.getSavedIds).thenReturn(const {});
    return ProviderContainer(
      overrides: [
        getRecipeByIdUseCaseProvider.overrideWithValue(getRecipeById),
        savedRecipeUseCasesProvider.overrideWithValue(savedUseCases),
      ],
    );
  }

  testWidgets('a free recipe unlocks ingredients immediately', (
    tester,
  ) async {
    final recipe = _recipe(badge: 'Free');
    final container = buildContainer(recipe);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: RecipeDetailView(recipeId: recipe.id)),
      ),
    );
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'FREE RECIPE'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);
  });

  testWidgets('a normal recipe that is not owned prompts a purchase', (
    tester,
  ) async {
    final recipe = _recipe(badge: 'Normal');
    final container = buildContainer(recipe);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: RecipeDetailView(recipeId: recipe.id)),
      ),
    );
    await tester.pump();

    expect(
      find.widgetWithText(ElevatedButton, 'BUY RECIPE • NPR 250'),
      findsOneWidget,
    );
    expect(find.text('Purchase to unlock the full recipe'), findsOneWidget);
    expect(find.text('Ingredients'), findsNothing);
  });

  testWidgets('an owned Pro recipe still requires Pro membership', (
    tester,
  ) async {
    final recipe = _recipe(badge: 'Pro');
    final container = buildContainer(recipe);
    addTearDown(container.dispose);
    container.read(purchaseViewModelProvider.notifier).state = PurchaseState(
      orders: [
        PurchaseOrderEntity(
          id: 'order-1',
          orderNumber: 'ORD-1',
          recipe: recipe,
          price: 250,
          purchasedAt: testDate,
          paymentMethod: 'e-Sewa',
          status: 'Completed',
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: RecipeDetailView(recipeId: recipe.id)),
      ),
    );
    await tester.pump();

    expect(
      find.widgetWithText(ElevatedButton, 'GET PRO TO ACCESS'),
      findsOneWidget,
    );
    expect(find.text('Pro membership required'), findsOneWidget);
  });
}
