import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/usecases/app_usecase.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
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
}

class RegisterUseCase implements UsecaseWithParams<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  @override
  Future<AppResult<bool>> call(RegisterParams params) {
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
