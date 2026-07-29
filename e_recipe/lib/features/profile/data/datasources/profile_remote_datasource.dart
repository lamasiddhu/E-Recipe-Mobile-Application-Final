import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/features/profile/data/models/profile_model.dart';

abstract interface class IProfileRemoteDatasource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
  });

  Future<ProfileModel> uploadAvatar(String filePath);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDatasource implements IProfileRemoteDatasource {
  final ApiClient _apiClient;

  ProfileRemoteDatasource(this._apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMe);
      return ProfileModel.fromJson(
        Map<String, dynamic>.from(response.data['data']),
      );
    } on DioException catch (error) {
      throw _exception(error, 'Unable to load your profile.');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'bio': bio,
        },
      );
      return ProfileModel.fromJson(
        Map<String, dynamic>.from(response.data['data']),
      );
    } on DioException catch (error) {
      throw _exception(error, 'Unable to update your profile.');
    }
  }

  @override
  Future<ProfileModel> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });
      final response = await _apiClient.post(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );
      return ProfileModel.fromJson(
        Map<String, dynamic>.from(response.data['data']),
      );
    } on DioException catch (error) {
      throw _exception(error, 'Unable to upload your profile image.');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put(
        ApiEndpoints.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (error) {
      throw _exception(error, 'Unable to change your password.');
    }
  }

  ApiException _exception(DioException error, String fallback) {
    final data = error.response?.data;
    final rawMessage = data is Map<String, dynamic> ? data['message'] : null;
    final message = rawMessage is List
        ? rawMessage.map((value) => value.toString()).join('\n')
        : rawMessage?.toString();
    return ApiException(
      statusCode: error.response?.statusCode,
      message: message == null || message.isEmpty ? fallback : message,
    );
  }
}
