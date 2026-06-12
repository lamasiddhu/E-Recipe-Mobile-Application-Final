import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:e_recipe/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:e_recipe/features/auth/data/models/auth_hive_model.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authLocalDatasourceProvider),
  );
});

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user == null) {
        return const Left(LocalDatabaseFailure(message: 'No active session.'));
      }
      return Right(user.toEntity());
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final user = await _authDatasource.login(email, password);
      if (user == null) {
        return const Left(
          LocalDatabaseFailure(message: 'Invalid email or password.'),
        );
      }
      return Right(user.toEntity());
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      return Right(await _authDatasource.logout());
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      if (await _authDatasource.isEmailExists(entity.email)) {
        return const Left(
          LocalDatabaseFailure(message: 'This email is already registered.'),
        );
      }

      final model = AuthHiveModel.fromEntity(entity);
      return Right(await _authDatasource.register(model));
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }
}
