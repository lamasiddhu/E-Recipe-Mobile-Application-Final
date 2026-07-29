import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<AppResult<bool>> call() {
    return _authRepository.logout();
  }
}
