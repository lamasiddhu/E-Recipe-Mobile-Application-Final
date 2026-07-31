import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:e_recipe/features/auth/data/models/auth_hive_model.dart';
import 'package:e_recipe/features/auth/data/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthDatasource extends Mock implements IAuthDatasource {}

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthDatasource datasource;
    late AuthRepositoryImpl repository;

    setUp(() {
      datasource = MockAuthDatasource();
      repository = AuthRepositoryImpl(datasource);
    });

    test('maps the datasource model into a domain user', () async {
      final model = AuthHiveModel(
        userId: 'user-1',
        firstName: 'Siddhartha',
        lastName: 'Lama',
        email: 'user@example.com',
        phone: '9800000000',
        password: '',
      );
      when(
        () => datasource.login('user@example.com', 'Password1!'),
      ).thenAnswer((_) async => model);

      final result = await repository.login('user@example.com', 'Password1!');

      expect(result, isA<ResultSuccess<AuthEntity>>());
      result.fold(
        (_) => fail('Expected success'),
        (user) => expect(user.displayName, 'Siddhartha Lama'),
      );
    });

    test('maps API errors into a failure without throwing', () async {
      when(() => datasource.login(any(), any())).thenThrow(
        const ApiException(statusCode: 401, message: 'Invalid login'),
      );

      final result = await repository.login('bad@example.com', 'bad');

      expect(result, isA<ResultFailure<AuthEntity>>());
      result.fold(
        (failure) => expect(failure.message, 'Invalid login'),
        (_) => fail('Expected failure'),
      );
    });
  });
}
