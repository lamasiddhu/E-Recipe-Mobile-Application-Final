import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/data/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

class LogoutUseCase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}
