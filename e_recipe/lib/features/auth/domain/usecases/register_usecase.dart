import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/data/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        password,
      ];
}

class RegisterUseCase implements UsecaseWithParams<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    final user = AuthEntity(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      password: params.password,
    );

    return _authRepository.register(user);
  }
}
