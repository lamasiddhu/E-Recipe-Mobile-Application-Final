import 'package:e_recipe/features/recipe/presentation/widgets/recipe_access_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('recipe access badge displays each access level', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              RecipeAccessBadge(badge: 'Free'),
              RecipeAccessBadge(badge: 'Normal'),
              RecipeAccessBadge(badge: 'Pro'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);
  });
}
