import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/admin/domain/repositories/admin_repository.dart';
import 'package:e_recipe/features/admin/domain/usecases/admin_usecases.dart';
import 'package:e_recipe/features/auth/domain/repositories/password_recovery_repository.dart';
import 'package:e_recipe/features/auth/domain/usecases/password_recovery_usecases.dart';
import 'package:e_recipe/features/favorites/domain/repositories/saved_recipes_repository.dart';
import 'package:e_recipe/features/favorites/domain/usecases/saved_recipe_usecases.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_extras_repository.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_repository.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_extras_usecases.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}
class MockPasswordRecoveryRepository extends Mock
    implements PasswordRecoveryRepository {}
class MockSavedRecipesRepository extends Mock
    implements SavedRecipesRepository {}
class MockProfileRepository extends Mock implements IProfileRepository {}
class MockProfileExtrasRepository extends Mock
    implements ProfileExtrasRepository {}

const profile = ProfileEntity(
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
  group('AdminUseCases', () {
    late MockAdminRepository repository;
    late AdminUseCases useCases;

    setUp(() {
      repository = MockAdminRepository();
      useCases = AdminUseCases(repository);
    });

    test('loads dashboard metrics', () async {
      when(repository.dashboard).thenAnswer((_) async => {'users': 2});
      expect(await useCases.dashboard(), {'users': 2});
      verify(repository.dashboard).called(1);
    });
    test('loads users', () async {
      when(repository.users).thenAnswer((_) async => [
        {'id': '1'},
      ]);
      expect(await useCases.users(), hasLength(1));
    });
    test('loads orders', () async {
      when(repository.orders).thenAnswer((_) async => [
        {'id': 'o1'},
      ]);
      expect(await useCases.orders(), hasLength(1));
    });
    test('loads recipes', () async {
      when(repository.recipes).thenAnswer((_) async => [
        {'id': 'r1'},
      ]);
      expect(await useCases.recipes(), hasLength(1));
    });
    test('loads settings', () async {
      when(repository.settings).thenAnswer((_) async => {'maintenance': false});
      expect((await useCases.settings())['maintenance'], isFalse);
    });
    test('updates user role and Pro status', () async {
      when(
        () => repository.updateUser('1', role: 'admin', isPro: true),
      ).thenAnswer((_) async {});
      await useCases.updateUser('1', role: 'admin', isPro: true);
      verify(
        () => repository.updateUser('1', role: 'admin', isPro: true),
      ).called(1);
    });
    test('sends user notification', () async {
      when(
        () => repository.notifyUser('1', 'Hello'),
      ).thenAnswer((_) async {});
      await useCases.notifyUser('1', 'Hello');
      verify(() => repository.notifyUser('1', 'Hello')).called(1);
    });
    test('sends recovery notification', () async {
      when(() => repository.sendRecovery('1')).thenAnswer((_) async {});
      await useCases.sendRecovery('1');
      verify(() => repository.sendRecovery('1')).called(1);
    });
    test('deletes user', () async {
      when(() => repository.deleteUser('1')).thenAnswer((_) async {});
      await useCases.deleteUser('1');
      verify(() => repository.deleteUser('1')).called(1);
    });
    test('removes purchased recipe', () async {
      when(
        () => repository.removePurchase('1', 'r1'),
      ).thenAnswer((_) async {});
      await useCases.removePurchase('1', 'r1');
      verify(() => repository.removePurchase('1', 'r1')).called(1);
    });
    test('adds recipe', () async {
      when(() => repository.addRecipe({'title': 'Dal'})).thenAnswer((_) async {});
      await useCases.addRecipe({'title': 'Dal'});
      verify(() => repository.addRecipe({'title': 'Dal'})).called(1);
    });
    test('updates recipe', () async {
      when(
        () => repository.updateRecipe('r1', {'title': 'Dal'}),
      ).thenAnswer((_) async {});
      await useCases.updateRecipe('r1', {'title': 'Dal'});
      verify(() => repository.updateRecipe('r1', {'title': 'Dal'})).called(1);
    });
    test('broadcasts announcement', () async {
      when(
        () => repository.broadcast('News', type: 'announcement'),
      ).thenAnswer((_) async {});
      await useCases.broadcast('News');
      verify(
        () => repository.broadcast('News', type: 'announcement'),
      ).called(1);
    });
    test('changes maintenance mode', () async {
      when(() => repository.maintenance(true)).thenAnswer((_) async {});
      await useCases.maintenance(true);
      verify(() => repository.maintenance(true)).called(1);
    });
    test('clears server cache', () async {
      when(repository.clearCache).thenAnswer((_) async {});
      await useCases.clearCache();
      verify(repository.clearCache).called(1);
    });
  });

  group('Profile use cases', () {
    late MockProfileRepository repository;
    setUp(() => repository = MockProfileRepository());

    test('gets profile', () async {
      when(
        repository.getProfile,
      ).thenAnswer((_) async => const ResultSuccess(profile));
      expect(await GetProfileUseCase(repository)(), isA<ResultSuccess>());
    });
    test('updates profile fields', () async {
      when(
        () => repository.updateProfile(
          firstName: 'Sita',
          lastName: 'Rai',
          phone: '9800000000',
          bio: 'Cook',
        ),
      ).thenAnswer((_) async => const ResultSuccess(profile));
      final result = await UpdateProfileUseCase(repository)(
        const UpdateProfileParams(
          firstName: 'Sita',
          lastName: 'Rai',
          phone: '9800000000',
          bio: 'Cook',
        ),
      );
      expect(result, isA<ResultSuccess>());
    });
    test('uploads avatar path', () async {
      when(
        () => repository.uploadAvatar('avatar.jpg'),
      ).thenAnswer((_) async => const ResultSuccess(profile));
      expect(
        await UploadAvatarUseCase(repository)('avatar.jpg'),
        isA<ResultSuccess>(),
      );
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

  group('Password recovery use cases', () {
    late MockPasswordRecoveryRepository repository;
    late PasswordRecoveryUseCases useCases;
    setUp(() {
      repository = MockPasswordRecoveryRepository();
      useCases = PasswordRecoveryUseCases(repository);
    });
    test('sends OTP', () async {
      when(() => repository.sendOtp('a@b.com')).thenAnswer((_) async {});
      await useCases.sendOtp('a@b.com');
      verify(() => repository.sendOtp('a@b.com')).called(1);
    });
    test('verifies OTP and returns reset token', () async {
      when(
        () => repository.verifyOtp('a@b.com', '123456'),
      ).thenAnswer((_) async => 'reset-token');
      expect(await useCases.verifyOtp('a@b.com', '123456'), 'reset-token');
    });
    test('resets forgotten password', () async {
      when(
        () => repository.resetPassword(
          email: 'a@b.com',
          resetToken: 'token',
          newPassword: 'new-password',
        ),
      ).thenAnswer((_) async {});
      await useCases.resetPassword(
        email: 'a@b.com',
        resetToken: 'token',
        newPassword: 'new-password',
      );
      verify(
        () => repository.resetPassword(
          email: 'a@b.com',
          resetToken: 'token',
          newPassword: 'new-password',
        ),
      ).called(1);
    });
  });

  group('Saved recipe use cases', () {
    test('loads saved IDs', () {
      final repository = MockSavedRecipesRepository();
      when(repository.getSavedIds).thenReturn({'r1', 'r2'});
      expect(SavedRecipeUseCases(repository).getSavedIds(), hasLength(2));
    });
    test('persists saved IDs', () async {
      final repository = MockSavedRecipesRepository();
      when(() => repository.saveIds({'r1'})).thenAnswer((_) async {});
      await SavedRecipeUseCases(repository).saveIds({'r1'});
      verify(() => repository.saveIds({'r1'})).called(1);
    });
  });

  group('Profile extras use cases', () {
    late MockProfileExtrasRepository repository;
    late ProfileExtrasUseCases useCases;
    setUp(() {
      repository = MockProfileExtrasRepository();
      useCases = ProfileExtrasUseCases(repository);
    });
    test('loads notifications', () async {
      when(repository.notifications).thenAnswer((_) async => [
        {'read': false},
      ]);
      expect(await useCases.notifications(), hasLength(1));
    });
    test('marks all notifications read', () async {
      when(repository.markAllNotificationsRead).thenAnswer((_) async {});
      await useCases.markAllNotificationsRead();
      verify(repository.markAllNotificationsRead).called(1);
    });
    test('clears notifications', () async {
      when(repository.clearNotifications).thenAnswer((_) async {});
      await useCases.clearNotifications();
      verify(repository.clearNotifications).called(1);
    });
    test('reads local boolean setting', () {
      when(() => repository.readLocalSetting('dark', false)).thenReturn(true);
      expect(useCases.readLocalSetting('dark', false), isTrue);
    });
    test('writes local boolean setting', () async {
      when(
        () => repository.writeLocalSetting('compact', true),
      ).thenAnswer((_) async {});
      await useCases.writeLocalSetting('compact', true);
      verify(() => repository.writeLocalSetting('compact', true)).called(1);
    });
  });
}
