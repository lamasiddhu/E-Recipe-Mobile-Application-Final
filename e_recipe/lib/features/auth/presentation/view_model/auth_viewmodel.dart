import 'package:e_recipe/core/services/biometrics/biometric_service.dart';
import 'package:e_recipe/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/get_google_client_id_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_recipe/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final GetGoogleClientIdUseCase _getGoogleClientIdUseCase;
  late final GoogleLoginUseCase _googleLoginUseCase;
  late final GetCurrentUseCase _getCurrentUseCase;
  final BiometricService _biometricService = BiometricService();
  bool _googleInitialized = false;

  @override
  AuthState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _registerUseCase = ref.read(registerUseCaseProvider);
    _getGoogleClientIdUseCase = ref.read(getGoogleClientIdUseCaseProvider);
    _googleLoginUseCase = ref.read(googleLoginUseCaseProvider);
    _getCurrentUseCase = ref.read(getCurrentUseCaseProvider);
    return const AuthState();
  }

  Future<void> checkBiometricAvailability() async {
    final show =
        _biometricService.isEnabled &&
        _biometricService.hasSavedSession &&
        await _biometricService.isAvailable();
    state = state.copyWith(biometricAvailable: show);
  }

  Future<void> googleLogin() async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);
    try {
      if (!_googleInitialized) {
        final clientId = await _getGoogleClientIdUseCase();
        await GoogleSignIn.instance.initialize(serverClientId: clientId);
        _googleInitialized = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an identity token.');
      }
      final result = await _googleLoginUseCase(idToken);
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
    } on GoogleSignInException catch (error) {
      state = error.code == GoogleSignInExceptionCode.canceled
          ? state.copyWith(status: AuthStatus.initial)
          : state.copyWith(
              status: AuthStatus.error,
              message: 'Google sign-in failed: ${error.description}',
            );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> biometricLogin() async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);
    final authenticated = await _biometricService.authenticate(
      'Use your fingerprint to log in to E-Recipe',
    );
    if (!authenticated) {
      state = state.copyWith(status: AuthStatus.initial);
      return;
    }
    final restored = await _biometricService.restoreSession();
    if (!restored) {
      state = state.copyWith(
        status: AuthStatus.error,
        message:
            'No saved biometric login is available. Log in with your password once.',
      );
      return;
    }
    final result = await _getCurrentUseCase();
    result.fold(
      (failure) {
        _biometricService.clearSavedSession();
        state = state.copyWith(
          status: AuthStatus.error,
          message: failure.message,
        );
      },
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
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
