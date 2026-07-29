import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_usecases.dart';
import 'package:e_recipe/features/profile/presentation/state/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfile;
  late final UpdateProfileUseCase _updateProfile;
  late final UploadAvatarUseCase _uploadAvatar;
  late final ChangePasswordUseCase _changePassword;

  @override
  ProfileState build() {
    _getProfile = ref.read(getProfileUseCaseProvider);
    _updateProfile = ref.read(updateProfileUseCaseProvider);
    _uploadAvatar = ref.read(uploadAvatarUseCaseProvider);
    _changePassword = ref.read(changePasswordUseCaseProvider);
    return const ProfileState();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, clearMessage: true);
    final result = await _getProfile();
    result.fold(
      (failure) =>
          state = state.copyWith(loading: false, message: failure.message),
      (profile) => state = state.copyWith(
        loading: false,
        profile: profile,
        clearMessage: true,
      ),
    );
  }

  Future<AppResult<ProfileEntity>> update({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
  }) async {
    state = state.copyWith(saving: true, clearMessage: true);
    final result = await _updateProfile(
      UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
      ),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(saving: false, message: failure.message),
      (profile) => state = state.copyWith(
        saving: false,
        profile: profile,
        clearMessage: true,
      ),
    );
    return result;
  }

  Future<AppResult<ProfileEntity>> uploadAvatar(String path) async {
    state = state.copyWith(saving: true, clearMessage: true);
    final result = await _uploadAvatar(path);
    result.fold(
      (failure) =>
          state = state.copyWith(saving: false, message: failure.message),
      (profile) => state = state.copyWith(
        saving: false,
        profile: profile,
        clearMessage: true,
      ),
    );
    return result;
  }

  Future<AppResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _changePassword(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }
}
