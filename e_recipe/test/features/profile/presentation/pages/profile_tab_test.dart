import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/presentation/pages/profile_tab.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

const _profile = ProfileEntity(
  id: 'user-1',
  firstName: 'Sita',
  lastName: 'Rai',
  email: 'sita@example.com',
  phone: '9800000000',
  bio: '',
  profilePicture: '',
  role: 'user',
  isPro: false,
);

void main() {
  testWidgets('shows a retry state when the profile fails to load', (
    tester,
  ) async {
    final getProfile = MockGetProfileUseCase();
    when(getProfile.call).thenAnswer(
      (_) async => const ResultFailure(ApiFailure(message: 'Offline')),
    );
    final container = ProviderContainer(
      overrides: [getProfileUseCaseProvider.overrideWithValue(getProfile)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: ProfileTab())),
      ),
    );
    // initState's addPostFrameCallback fires load(); pump again so the
    // mocked (already-resolved) future settles into the new state.
    await tester.pump();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Try again'), findsOneWidget);
  });

  testWidgets('renders the loaded profile', (tester) async {
    final getProfile = MockGetProfileUseCase();
    when(getProfile.call).thenAnswer((_) async => const ResultSuccess(_profile));
    final container = ProviderContainer(
      overrides: [getProfileUseCaseProvider.overrideWithValue(getProfile)],
    );
    addTearDown(container.dispose);
    await container.read(profileViewModelProvider.notifier).load();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: ProfileTab())),
      ),
    );

    expect(find.text('Sita Rai'), findsOneWidget);
    expect(find.text('sita@example.com'), findsOneWidget);
    expect(find.text('FREE MEMBER'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Log out'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.widgetWithText(OutlinedButton, 'Log out'), findsOneWidget);
  });

  testWidgets('tapping log out calls the logout use case', (tester) async {
    final getProfile = MockGetProfileUseCase();
    when(getProfile.call).thenAnswer((_) async => const ResultSuccess(_profile));
    final logout = MockLogoutUseCase();
    when(logout.call).thenAnswer((_) async => const ResultSuccess(true));
    final container = ProviderContainer(
      overrides: [
        getProfileUseCaseProvider.overrideWithValue(getProfile),
        logoutUseCaseProvider.overrideWithValue(logout),
        // Logging out navigates to LoginScreen, whose initState touches
        // biometrics/Hive for real unless neutralized here.
        authViewModelProvider.overrideWith(FakeAuthViewModel.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(profileViewModelProvider.notifier).load();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: ProfileTab())),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Log out'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Log out'));
    await tester.pump();

    verify(logout.call).called(1);
  });
}
