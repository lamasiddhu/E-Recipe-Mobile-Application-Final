import 'package:e_recipe/features/auth/domain/repositories/password_recovery_repository.dart';
import 'package:e_recipe/features/auth/domain/usecases/password_recovery_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPasswordRecoveryRepository extends Mock
    implements PasswordRecoveryRepository {}

void main() {
  group('Password recovery use cases', () {
    late MockPasswordRecoveryRepository repository;
    late PasswordRecoveryUseCases useCases;
    setUp(() {
      repository = MockPasswordRecoveryRepository();
      useCases = PasswordRecoveryUseCases(repository);
    });
    test('sends OTP', () async {
      when(() => repository.sendOtp('a@b.com')).thenAnswer((_) async {});
      await useCases.sendOtp('a@b.com');
      verify(() => repository.sendOtp('a@b.com')).called(1);
    });
    test('resets forgotten password', () async {
      when(
        () => repository.resetPassword(
          email: 'a@b.com',
          resetToken: 'token',
          newPassword: 'new-password',
        ),
      ).thenAnswer((_) async {});
      await useCases.resetPassword(
        email: 'a@b.com',
        resetToken: 'token',
        newPassword: 'new-password',
      );
      verify(
        () => repository.resetPassword(
          email: 'a@b.com',
          resetToken: 'token',
          newPassword: 'new-password',
        ),
      ).called(1);
    });
  });
}
