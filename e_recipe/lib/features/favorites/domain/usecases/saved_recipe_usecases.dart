import 'package:e_recipe/features/favorites/domain/repositories/saved_recipes_repository.dart';

class SavedRecipeUseCases {
  final SavedRecipesRepository _repository;
  SavedRecipeUseCases(this._repository);
  Set<String> getSavedIds() => _repository.getSavedIds();
  Future<void> saveIds(Set<String> ids) => _repository.saveIds(ids);
}
