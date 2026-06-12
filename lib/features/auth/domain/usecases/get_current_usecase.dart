import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/data/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getCurrentUseCaseProvider = Provider<GetCurrentUseCase>((ref) {
  return GetCurrentUseCase(ref.read(authRepositoryProvider));
});

class GetCurrentUseCase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUseCase(this._authRepository);

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _authRepository.getCurrentUser();
  }
}
