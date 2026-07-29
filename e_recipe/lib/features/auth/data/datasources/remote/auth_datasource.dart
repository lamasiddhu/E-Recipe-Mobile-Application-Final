import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/features/auth/data/models/auth_hive_model.dart';
import 'package:dio/dio.dart';

abstract interface class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel> loginWithGoogle(String idToken);
  Future<String> getGoogleClientId();
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
}

class AuthRemoteDatasource implements IAuthDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'firstName': model.firstName,
          'lastName': model.lastName,
          'email': model.email,
          'phone': model.phone,
          'password': model.password,
        },
      );

      return response.data['success'] == true;
    } on DioException catch (error) {
      throw _toApiException(error, 'Unable to create your account.');
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      final token = response.data['token'];
      if (token != null) {
        await _apiClient.saveToken(token);
      }

      return AuthHiveModel(
        userId: data['_id'] as String?,
        firstName: data['firstName'] as String? ?? '',
        lastName: data['lastName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        password: password,
      );
    } on DioException catch (error) {
      throw _toApiException(error, 'Unable to log in.');
    }
  }

  @override
  Future<String> getGoogleClientId() async {
    try {
      final response = await _apiClient.get('/users/google-config');
      return response.data['data']['clientId'] as String;
    } on DioException catch (error) {
      throw _toApiException(error, 'Unable to load Google login.');
    }
  }

  @override
  Future<AuthHiveModel> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.post(
        '/users/google',
        data: {'idToken': idToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final token = response.data['token'] as String?;
      if (token != null) await _apiClient.saveToken(token);
      return AuthHiveModel(
        userId: data['_id'] as String?,
        firstName: data['firstName'] as String? ?? '',
        lastName: data['lastName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        password: '',
      );
    } on DioException catch (error) {
      throw _toApiException(error, 'Unable to sign in with Google.');
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMe);
      final data = response.data['data'];
      return AuthHiveModel(
        userId: data['_id'] as String?,
        firstName: data['firstName'] as String? ?? '',
        lastName: data['lastName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        password: '',
      );
    } catch (error) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    await _apiClient.clearToken();
    return true;
  }

  @override
  Future<bool> isEmailExists(String email) async {
    // Backend handles email uniqueness during registration,
    // so return false here and allow the backend to validate.
    return false;
  }

  ApiException _toApiException(DioException error, String fallback) {
    final responseData = error.response?.data;
    final rawMessage = responseData is Map<String, dynamic>
        ? responseData['message']
        : null;
    final message = rawMessage is List
        ? rawMessage.map((item) => item.toString()).join('\n')
        : rawMessage?.toString();
    return ApiException(
      statusCode: error.response?.statusCode,
      message: message == null || message.isEmpty ? fallback : message,
    );
  }
}
