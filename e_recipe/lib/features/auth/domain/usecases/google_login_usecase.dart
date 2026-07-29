import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';

class GoogleLoginUseCase {
  final IAuthRepository _repository;

  GoogleLoginUseCase(this._repository);

  Future<AppResult<AuthEntity>> call(String idToken) {
    return _repository.loginWithGoogle(idToken);
  }
}
