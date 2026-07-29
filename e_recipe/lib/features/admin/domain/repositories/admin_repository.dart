abstract interface class AdminRepository {
  Future<Map<String, dynamic>> dashboard();
  Future<List<Map<String, dynamic>>> users();
  Future<List<Map<String, dynamic>>> orders();
  Future<List<Map<String, dynamic>>> recipes();
  Future<Map<String, dynamic>> settings();
  Future<void> updateUser(String id, {String? role, bool? isPro});
  Future<void> deleteUser(String id);
  Future<void> notifyUser(String id, String message);
  Future<void> sendRecovery(String id);
  Future<void> removePurchase(String userId, String recipeId);
  Future<void> deleteRecipe(String id);
  Future<void> addRecipe(Map<String, dynamic> recipe);
  Future<void> updateRecipe(String id, Map<String, dynamic> recipe);
  Future<String> uploadRecipeImage(String path);
  Future<void> broadcast(String message, {String type});
  Future<void> maintenance(bool enabled);
  Future<void> clearCache();
}
