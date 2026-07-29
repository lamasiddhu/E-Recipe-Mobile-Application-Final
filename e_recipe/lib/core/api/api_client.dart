import 'package:dio/dio.dart';
import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'api_endpoints.dart';
import 'package:e_recipe/core/services/biometrics/biometric_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor to automatically add JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _session.get(HiveTableConstant.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // If token is expired (401), clear it
          if (error.response?.statusCode == 401) {
            await _session.delete(HiveTableConstant.authTokenKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
  Box<String> get _session => Hive.box<String>(HiveTableConstant.sessionBox);

  // Save token after login
  Future<void> saveToken(String token) async {
    await _session.put(HiveTableConstant.authTokenKey, token);
    await BiometricService().rememberCurrentSession();
  }

  // Clear token on logout
  Future<void> clearToken() async {
    await _session.delete(HiveTableConstant.authTokenKey);
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  // DELETE request
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
