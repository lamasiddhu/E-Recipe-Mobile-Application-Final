import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_repository.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

const _profile = ProfileEntity(
  id: 'user-1',
  firstName: 'Sita',
  lastName: 'Rai',
  email: 'sita@example.com',
  phone: '9800000000',
  bio: 'Home cook',
  profilePicture: '',
  role: 'user',
  isPro: false,
);

void main() {
  group('Profile use cases', () {
    late MockProfileRepository repository;
    setUp(() => repository = MockProfileRepository());

    test('gets profile', () async {
      when(
        repository.getProfile,
      ).thenAnswer((_) async => const ResultSuccess(_profile));
      expect(await GetProfileUseCase(repository)(), isA<ResultSuccess>());
    });
    test('changes password', () async {
      when(
        () => repository.changePassword(
          currentPassword: 'old',
          newPassword: 'new-password',
        ),
      ).thenAnswer((_) async => const ResultSuccess(null));
      expect(
        await ChangePasswordUseCase(repository)(
          const ChangePasswordParams(
            currentPassword: 'old',
            newPassword: 'new-password',
          ),
        ),
        isA<ResultSuccess<void>>(),
      );
    });
  });
}
