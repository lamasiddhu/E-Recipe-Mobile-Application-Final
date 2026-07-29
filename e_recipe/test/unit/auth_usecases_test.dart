import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/logout_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUpAll(() => registerFallbackValue(testUser));
  setUp(() => repository = MockAuthRepository());

  test(
    'login delegates credentials and returns the authenticated user',
    () async {
      when(
        () => repository.login(testUser.email, testUser.password),
      ).thenAnswer((_) async => const ResultSuccess(testUser));

      final result = await LoginUseCase(repository)(
        LoginParams(email: testUser.email, password: testUser.password),
      );

      expect(result, isA<ResultSuccess<AuthEntity>>());
      verify(
        () => repository.login(testUser.email, testUser.password),
      ).called(1);
    },
  );

  test('registration creates the expected domain entity', () async {
    when(
      () => repository.register(any()),
    ).thenAnswer((_) async => const ResultSuccess(true));

    final result = await RegisterUseCase(repository)(
      const RegisterParams(
        firstName: 'Siddhartha',
        lastName: 'Lama',
        email: 'user@example.com',
        phone: '9800000000',
        password: 'Password1!',
      ),
    );

    expect(result, isA<ResultSuccess<bool>>());
    final captured =
        verify(() => repository.register(captureAny())).captured.single
            as AuthEntity;
    expect(captured.displayName, 'Siddhartha Lama');
    expect(captured.email, 'user@example.com');
  });

  test('Google login delegates the ID token', () async {
    when(
      () => repository.loginWithGoogle('google-token'),
    ).thenAnswer((_) async => const ResultSuccess(testUser));

    final result = await GoogleLoginUseCase(repository)('google-token');

    expect(result, isA<ResultSuccess<AuthEntity>>());
    verify(() => repository.loginWithGoogle('google-token')).called(1);
  });

  test('get current user and logout preserve repository results', () async {
    when(
      repository.getCurrentUser,
    ).thenAnswer((_) async => const ResultSuccess(testUser));
    when(repository.logout).thenAnswer((_) async => const ResultSuccess(true));

    expect(
      await GetCurrentUseCase(repository)(),
      isA<ResultSuccess<AuthEntity>>(),
    );
    expect(await LogoutUseCase(repository)(), isA<ResultSuccess<bool>>());
  });
}
