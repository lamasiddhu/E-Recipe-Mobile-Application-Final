import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus { initial, loading, authenticated, registered, error }

class AuthState {
  final AuthStatus status;
  final AuthEntity? user;
  final String? message;

  const AuthState({this.status = AuthStatus.initial, this.user, this.message});

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
