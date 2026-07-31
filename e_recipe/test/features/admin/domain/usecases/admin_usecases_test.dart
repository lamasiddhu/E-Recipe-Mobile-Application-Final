import 'package:e_recipe/features/admin/domain/repositories/admin_repository.dart';
import 'package:e_recipe/features/admin/domain/usecases/admin_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

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
    test('updates user role and Pro status', () async {
      when(
        () => repository.updateUser('1', role: 'admin', isPro: true),
      ).thenAnswer((_) async {});
      await useCases.updateUser('1', role: 'admin', isPro: true);
      verify(
        () => repository.updateUser('1', role: 'admin', isPro: true),
      ).called(1);
    });
    test('changes maintenance mode', () async {
      when(() => repository.maintenance(true)).thenAnswer((_) async {});
      await useCases.maintenance(true);
      verify(() => repository.maintenance(true)).called(1);
    });
  });
}
