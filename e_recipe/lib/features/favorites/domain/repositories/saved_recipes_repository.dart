abstract interface class SavedRecipesRepository {
  Set<String> getSavedIds();
  Future<void> saveIds(Set<String> ids);
}
