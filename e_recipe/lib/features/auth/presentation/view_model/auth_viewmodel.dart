import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_recipe/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  @override
  AuthState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _registerUseCase = ref.read(registerUseCaseProvider);
    return const AuthState();
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    final result = await _loginUseCase(
      LoginParams(email: email.trim(), password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        message: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        message: 'Welcome back, ${user.firstName}!',
      ),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    final result = await _registerUseCase(
      RegisterParams(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        message: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.registered,
        message: 'Account created successfully! Please log in.',
      ),
    );
  }
}
