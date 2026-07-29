import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';
import 'package:e_recipe/features/recipe_ai/domain/usecases/generate_recipe_usecase.dart';
import 'package:e_recipe/features/recipe_ai/presentation/pages/ai_recipe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockGenerateRecipeUseCase extends Mock implements GenerateRecipeUseCase {}

void main() {
  testWidgets('food question renders AI response and database recommendation', (
    tester,
  ) async {
    final useCase = MockGenerateRecipeUseCase();
    when(() => useCase(any(), history: any(named: 'history'))).thenAnswer(
      (_) async => RecipeAiResponse(
        message: 'Try this spicy curry from E-Recipe.',
        recommendations: [
          RecipeRecommendation(
            recipe: testRecipe,
            reason: 'It matches your spicy-food preference.',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [generateRecipeUseCaseProvider.overrideWithValue(useCase)],
        child: const MaterialApp(home: AiRecipePage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'I want something spicy');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('I want something spicy'), findsOneWidget);
    expect(find.text('Try this spicy curry from E-Recipe.'), findsOneWidget);
    expect(find.text('Spicy Chicken Curry'), findsOneWidget);
    verify(
      () => useCase('I want something spicy', history: any(named: 'history')),
    ).called(1);
  });
}
