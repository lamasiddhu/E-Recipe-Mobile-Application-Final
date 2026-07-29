import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<AppResult<bool>> register(AuthEntity entity);
  Future<AppResult<AuthEntity>> login(String email, String password);
  Future<AppResult<AuthEntity>> loginWithGoogle(String idToken);
  Future<AppResult<AuthEntity>> getCurrentUser();
  Future<AppResult<bool>> logout();
  Future<String> getGoogleClientId();
}
