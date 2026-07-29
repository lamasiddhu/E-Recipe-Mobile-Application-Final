import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDatasource _datasource;

  ProfileRepositoryImpl(this._datasource);

  @override
  Future<AppResult<ProfileEntity>> getProfile() =>
      _guard(() async => (await _datasource.getProfile()).toEntity());

  @override
  Future<AppResult<ProfileEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
  }) {
    return _guard(
      () async => (await _datasource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
      )).toEntity(),
    );
  }

  @override
  Future<AppResult<ProfileEntity>> uploadAvatar(String filePath) {
    return _guard(
      () async => (await _datasource.uploadAvatar(filePath)).toEntity(),
    );
  }

  @override
  Future<AppResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _guard(
      () => _datasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<AppResult<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return ResultSuccess(await operation());
    } on ApiException catch (error) {
      return ResultFailure(
        ApiFailure(statusCode: error.statusCode, message: error.message),
      );
    } catch (_) {
      return const ResultFailure(
        ApiFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }
}
