import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/presentation/pages/login_screen.dart';
import 'package:e_recipe/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  setUpAll(() => registerFallbackValue(
        LoginParams(email: testUser.email, password: testUser.password),
      ));

  ProviderContainer buildContainer(MockLoginUseCase loginUseCase) {
    return ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(loginUseCase),
        authViewModelProvider.overrideWith(FakeAuthViewModel.new),
      ],
    );
  }

  testWidgets('renders the login form with a User/Admin toggle', (
    tester,
  ) async {
    final container = buildContainer(MockLoginUseCase());
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('E-Recipe'), findsOneWidget);
    expect(find.text('User Login'), findsOneWidget);
    expect(find.text('Admin Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('shows a validation error when submitted empty', (
    tester,
  ) async {
    final loginUseCase = MockLoginUseCase();
    final container = buildContainer(loginUseCase);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please enter email or ID'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
    verifyNever(() => loginUseCase(any()));
  });

  testWidgets('shows the backend error message on failed login', (
    tester,
  ) async {
    final loginUseCase = MockLoginUseCase();
    when(() => loginUseCase(any())).thenAnswer(
      (_) async =>
          const ResultFailure(ApiFailure(message: 'Invalid credentials')),
    );
    final container = buildContainer(loginUseCase);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      testUser.email,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      testUser.password,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Invalid credentials'), findsOneWidget);
    verify(() => loginUseCase(any())).called(1);
  });
}
