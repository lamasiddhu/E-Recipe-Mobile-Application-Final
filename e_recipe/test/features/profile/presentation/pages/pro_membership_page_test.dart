import 'package:e_recipe/features/profile/presentation/pages/pro_membership_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(home: ProMembershipPage()),
  );

  testWidgets('renders the pro pitch and benefit list', (tester) async {
    await pump(tester);

    expect(find.text('E-Recipe Pro'), findsOneWidget);
    expect(find.text('Cook without limits'), findsOneWidget);
    expect(find.text('Unlimited recipe access'), findsOneWidget);
    expect(find.text('Exclusive Pro recipes'), findsOneWidget);
    expect(find.text('Custom recipe collections'), findsOneWidget);
    expect(find.text('Ad-free experience'), findsOneWidget);
  });

  testWidgets('shows benefit icons alongside each row', (tester) async {
    await pump(tester);

    expect(find.byIcon(Icons.menu_book), findsOneWidget);
    expect(find.byIcon(Icons.star_outline), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byIcon(Icons.block), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
  });

  testWidgets('shows a GET PRO button', (tester) async {
    await pump(tester);

    expect(find.widgetWithText(ElevatedButton, 'GET PRO'), findsOneWidget);
  });

  testWidgets('tapping GET PRO shows the coming-soon snackbar', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'GET PRO'));
    await tester.pump();

    expect(
      find.text('e-Sewa payment will be connected next.'),
      findsOneWidget,
    );
  });
}
