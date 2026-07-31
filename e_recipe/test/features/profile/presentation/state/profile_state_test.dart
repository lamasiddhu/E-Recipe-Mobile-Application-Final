import 'package:e_recipe/features/profile/presentation/state/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileState', () {
    test('clearMessage removes profile error', () {
      expect(
        const ProfileState(
          message: 'error',
        ).copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });
}
