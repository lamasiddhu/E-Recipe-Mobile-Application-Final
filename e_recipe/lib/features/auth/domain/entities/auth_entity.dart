import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  const AuthEntity({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  String get displayName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        phone,
        password,
      ];
}
