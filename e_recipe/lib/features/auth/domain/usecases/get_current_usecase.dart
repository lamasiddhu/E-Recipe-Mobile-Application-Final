import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUseCase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUseCase(this._authRepository);

  @override
  Future<AppResult<AuthEntity>> call() {
    return _authRepository.getCurrentUser();
  }
}
