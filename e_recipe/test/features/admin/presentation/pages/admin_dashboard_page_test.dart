import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  testWidgets('settings tab reflects the current maintenance mode state', (
    tester,
  ) async {
    final adminUseCases = MockAdminUseCases();
    when(adminUseCases.dashboard).thenAnswer((_) async => <String, dynamic>{});
    when(adminUseCases.users).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(adminUseCases.orders).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(
      adminUseCases.recipes,
    ).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(
      adminUseCases.settings,
    ).thenAnswer((_) async => {'maintenanceMode': true});
    final profileExtras = MockProfileExtrasUseCases();
    when(profileExtras.notifications).thenAnswer((_) async => []);
    final getProfile = MockGetProfileUseCase();
    when(getProfile.call).thenAnswer(
      (_) async => const ResultFailure(ApiFailure(message: 'n/a')),
    );
    final container = ProviderContainer(
      overrides: [
        adminUseCasesProvider.overrideWithValue(adminUseCases),
        profileExtrasUseCasesProvider.overrideWithValue(profileExtras),
        getProfileUseCaseProvider.overrideWithValue(getProfile),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AdminDashboardPage()),
      ),
    );
    // build() kicks off Future.microtask(loadAll); pump lets it settle.
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();

    final toggle = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Maintenance Mode'),
    );
    expect(toggle.value, isTrue);

    // The view model's 10s Timer.periodic only gets cancelled once the
    // provider itself is disposed (via ref.onDispose) — unmounting the
    // widget alone doesn't touch the container's provider lifecycle, and
    // addTearDown runs after flutter_test's pending-timer check. Dispose
    // explicitly here, before the test body returns.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });
}
