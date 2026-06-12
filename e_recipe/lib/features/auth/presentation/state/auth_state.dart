import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, registered, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

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

  @override
  List<Object?> get props => [status, user, message];
}
