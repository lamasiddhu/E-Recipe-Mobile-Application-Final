import 'package:e_recipe/features/admin/domain/repositories/admin_repository.dart';

class AdminUseCases implements AdminRepository {
  final AdminRepository _repository;

  AdminUseCases(this._repository);

  @override
  Future<Map<String, dynamic>> dashboard() => _repository.dashboard();
  @override
  Future<List<Map<String, dynamic>>> users() => _repository.users();
  @override
  Future<List<Map<String, dynamic>>> orders() => _repository.orders();
  @override
  Future<List<Map<String, dynamic>>> recipes() => _repository.recipes();
  @override
  Future<Map<String, dynamic>> settings() => _repository.settings();
  @override
  Future<void> updateUser(String id, {String? role, bool? isPro}) =>
      _repository.updateUser(id, role: role, isPro: isPro);
  @override
  Future<void> deleteUser(String id) => _repository.deleteUser(id);
  @override
  Future<void> notifyUser(String id, String message) =>
      _repository.notifyUser(id, message);
  @override
  Future<void> sendRecovery(String id) => _repository.sendRecovery(id);
  @override
  Future<void> removePurchase(String userId, String recipeId) =>
      _repository.removePurchase(userId, recipeId);
  @override
  Future<void> deleteRecipe(String id) => _repository.deleteRecipe(id);
  @override
  Future<void> addRecipe(Map<String, dynamic> recipe) =>
      _repository.addRecipe(recipe);
  @override
  Future<void> updateRecipe(String id, Map<String, dynamic> recipe) =>
      _repository.updateRecipe(id, recipe);
  @override
  Future<String> uploadRecipeImage(String path) =>
      _repository.uploadRecipeImage(path);
  @override
  Future<void> broadcast(String message, {String type = 'announcement'}) =>
      _repository.broadcast(message, type: type);
  @override
  Future<void> maintenance(bool enabled) => _repository.maintenance(enabled);
  @override
  Future<void> clearCache() => _repository.clearCache();
}
