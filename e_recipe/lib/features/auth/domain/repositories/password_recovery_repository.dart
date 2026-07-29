abstract interface class PasswordRecoveryRepository {
  Future<void> sendOtp(String email);
  Future<String> verifyOtp(String email, String otp);
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
