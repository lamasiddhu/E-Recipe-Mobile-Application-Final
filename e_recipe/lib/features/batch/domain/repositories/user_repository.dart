import 'package:dartz/dartz.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/batch/domain/entities/user_entity.dart';

abstract interface class UserRepository {
  // Sign up new user
  Future<Either<Failure, UserEntity>> registerUser(UserEntity user);
  
  // Login existing user
  Future<Either<Failure, UserEntity>> loginUser(String email, String password);
}