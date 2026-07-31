import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/profile/presentation/widgets/notification_bell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  testWidgets('shows an unread badge when there are unread notifications', (
    tester,
  ) async {
    final profileExtras = MockProfileExtrasUseCases();
    when(profileExtras.notifications).thenAnswer(
      (_) async => [
        {'read': false},
        {'read': true},
      ],
    );
    final container = ProviderContainer(
      overrides: [
        profileExtrasUseCasesProvider.overrideWithValue(profileExtras),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: NotificationBell(color: Colors.black)),
        ),
      ),
    );
    await tester.pump();

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);
    expect(find.text('1'), findsOneWidget);

    // Unmount before the test ends so the widget's periodic refresh Timer
    // gets cancelled via dispose(), instead of failing teardown as pending.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hides the badge when everything is read', (tester) async {
    final profileExtras = MockProfileExtrasUseCases();
    when(profileExtras.notifications).thenAnswer(
      (_) async => [
        {'read': true},
      ],
    );
    final container = ProviderContainer(
      overrides: [
        profileExtrasUseCasesProvider.overrideWithValue(profileExtras),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: NotificationBell(color: Colors.black)),
        ),
      ),
    );
    await tester.pump();

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
