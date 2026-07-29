import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/features/auth/domain/repositories/password_recovery_repository.dart';

class PasswordRecoveryDatasource implements PasswordRecoveryRepository {
  final ApiClient _api;

  PasswordRecoveryDatasource(this._api);

  @override
  Future<void> sendOtp(String email) async {
    try {
      await _api.post('/users/forgot-password', data: {'email': email});
    } on DioException catch (error) {
      throw _exception(error, 'Unable to send the verification code.');
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await _api.post(
        '/users/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return response.data['data']['resetToken'] as String;
    } on DioException catch (error) {
      throw _exception(error, 'Unable to verify the code.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _api.post(
        '/users/reset-password',
        data: {
          'email': email,
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (error) {
      throw _exception(error, 'Unable to reset your password.');
    }
  }

  ApiException _exception(DioException error, String fallback) {
    final data = error.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    return ApiException(
      statusCode: error.response?.statusCode,
      message: message == null || message.isEmpty ? fallback : message,
    );
  }
}
