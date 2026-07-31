import 'package:e_recipe/features/profile/domain/repositories/profile_extras_repository.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_extras_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileExtrasRepository extends Mock
    implements ProfileExtrasRepository {}

void main() {
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
    test('writes local boolean setting', () async {
      when(
        () => repository.writeLocalSetting('compact', true),
      ).thenAnswer((_) async {});
      await useCases.writeLocalSetting('compact', true);
      verify(() => repository.writeLocalSetting('compact', true)).called(1);
    });
  });
}
