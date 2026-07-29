import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';

class ProfileState {
  final bool loading;
  final bool saving;
  final ProfileEntity? profile;
  final String? message;

  const ProfileState({
    this.loading = false,
    this.saving = false,
    this.profile,
    this.message,
  });

  ProfileState copyWith({
    bool? loading,
    bool? saving,
    ProfileEntity? profile,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      profile: profile ?? this.profile,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
