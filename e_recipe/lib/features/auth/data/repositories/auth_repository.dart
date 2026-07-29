import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:e_recipe/features/auth/data/models/auth_hive_model.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Future<String> getGoogleClientId() => _authDatasource.getGoogleClientId();

  @override
  Future<AppResult<AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user == null) {
        return const ResultFailure(
          LocalDatabaseFailure(message: 'No active session.'),
        );
      }
      return ResultSuccess(user.toEntity());
    } catch (error) {
      return ResultFailure(LocalDatabaseFailure(message: _messageFrom(error)));
    }
  }

  @override
  Future<AppResult<AuthEntity>> login(String email, String password) async {
    try {
      final user = await _authDatasource.login(email, password);
      if (user == null) {
        return const ResultFailure(
          LocalDatabaseFailure(message: 'Invalid email or password.'),
        );
      }
      return ResultSuccess(user.toEntity());
    } catch (error) {
      return ResultFailure(LocalDatabaseFailure(message: _messageFrom(error)));
    }
  }

  @override
  Future<AppResult<AuthEntity>> loginWithGoogle(String idToken) async {
    try {
      final user = await _authDatasource.loginWithGoogle(idToken);
      return ResultSuccess(user.toEntity());
    } catch (error) {
      return ResultFailure(LocalDatabaseFailure(message: _messageFrom(error)));
    }
  }

  @override
  Future<AppResult<bool>> logout() async {
    try {
      return ResultSuccess(await _authDatasource.logout());
    } catch (error) {
      return ResultFailure(LocalDatabaseFailure(message: _messageFrom(error)));
    }
  }

  @override
  Future<AppResult<bool>> register(AuthEntity entity) async {
    try {
      if (await _authDatasource.isEmailExists(entity.email)) {
        return const ResultFailure(
          LocalDatabaseFailure(message: 'This email is already registered.'),
        );
      }

      final model = AuthHiveModel.fromEntity(entity);
      return ResultSuccess(await _authDatasource.register(model));
    } catch (error) {
      return ResultFailure(LocalDatabaseFailure(message: _messageFrom(error)));
    }
  }

  String _messageFrom(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
