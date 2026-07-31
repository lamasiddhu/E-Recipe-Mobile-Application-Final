import 'package:e_recipe/features/favorites/domain/repositories/saved_recipes_repository.dart';
import 'package:e_recipe/features/favorites/domain/usecases/saved_recipe_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSavedRecipesRepository extends Mock
    implements SavedRecipesRepository {}

void main() {
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
}
