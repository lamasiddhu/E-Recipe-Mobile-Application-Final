import 'package:e_recipe/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthState', () {
    test('defaults to initial', () {
      expect(const AuthState().status, AuthStatus.initial);
    });
    test('clearMessage removes message', () {
      expect(
        const AuthState(message: 'error').copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });
}
