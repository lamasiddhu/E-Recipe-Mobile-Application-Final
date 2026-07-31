import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_recipe/features/auth/presentation/pages/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockRegisterUseCase registerUseCase;

  setUpAll(() => registerFallbackValue(const RegisterParams(
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        password: '',
      )));

  setUp(() => registerUseCase = MockRegisterUseCase());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [registerUseCaseProvider.overrideWithValue(registerUseCase)],
      child: const MaterialApp(home: SignupView()),
    ),
  );

  testWidgets('renders the signup form without Google/Facebook buttons', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);

    // Regression check: these were removed and must not come back.
    expect(find.text('Google'), findsNothing);
    expect(find.text('Facebook'), findsNothing);
    expect(find.byIcon(Icons.facebook), findsNothing);
  });

  testWidgets('shows a terms-agreement checkbox', (tester) async {
    await pump(tester);

    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('I agree to the Terms & Conditions'), findsOneWidget);
  });

  testWidgets('blocks submission until terms are agreed to', (tester) async {
    await pump(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Lionel Messi',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'lionel@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '9800000000');
    await tester.enterText(find.byType(TextFormField).at(3), 'Password1!');
    await tester.enterText(find.byType(TextFormField).at(4), 'Password1!');

    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    expect(
      find.text('Please agree to the Terms & Conditions'),
      findsOneWidget,
    );
    verifyNever(() => registerUseCase(any()));
  });

  testWidgets('submits registration once the form is valid and agreed to', (
    tester,
  ) async {
    when(() => registerUseCase(any())).thenAnswer(
      (_) async => const ResultSuccess(true),
    );

    await pump(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Lionel Messi',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'lionel@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '9800000000');
    await tester.enterText(find.byType(TextFormField).at(3), 'Password1!');
    await tester.enterText(find.byType(TextFormField).at(4), 'Password1!');
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pump();

    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    verify(() => registerUseCase(any())).called(1);
  });
}
