import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus { initial, loading, authenticated, registered, error }

class AuthState {
  final AuthStatus status;
  final AuthEntity? user;
  final String? message;
  final bool biometricAvailable;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
    this.biometricAvailable = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? message,
    bool clearMessage = false,
    bool? biometricAvailable,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }
}
