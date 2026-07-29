import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<AppResult<ProfileEntity>> getProfile();

  Future<AppResult<ProfileEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
  });

  Future<AppResult<ProfileEntity>> uploadAvatar(String filePath);

  Future<AppResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
