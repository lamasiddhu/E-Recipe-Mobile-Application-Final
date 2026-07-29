import 'package:e_recipe/features/auth/domain/repositories/password_recovery_repository.dart';

class PasswordRecoveryUseCases {
  final PasswordRecoveryRepository _repository;
  PasswordRecoveryUseCases(this._repository);

  Future<void> sendOtp(String email) => _repository.sendOtp(email);
  Future<String> verifyOtp(String email, String otp) =>
      _repository.verifyOtp(email, otp);
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) => _repository.resetPassword(
    email: email,
    resetToken: resetToken,
    newPassword: newPassword,
  );
}
