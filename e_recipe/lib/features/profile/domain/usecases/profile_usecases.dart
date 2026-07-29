import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<AppResult<ProfileEntity>> call() => _repository.getProfile();
}

class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String phone;
  final String bio;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.bio,
  });
}

class UpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<AppResult<ProfileEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      bio: params.bio,
    );
  }
}

class UploadAvatarUseCase {
  final IProfileRepository _repository;

  UploadAvatarUseCase(this._repository);

  Future<AppResult<ProfileEntity>> call(String filePath) {
    return _repository.uploadAvatar(filePath);
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class ChangePasswordUseCase {
  final IProfileRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<AppResult<void>> call(ChangePasswordParams params) {
    return _repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
