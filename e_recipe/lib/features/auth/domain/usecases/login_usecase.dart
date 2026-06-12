import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/data/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase implements UsecaseWithParams<AuthEntity, LoginParams> {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
