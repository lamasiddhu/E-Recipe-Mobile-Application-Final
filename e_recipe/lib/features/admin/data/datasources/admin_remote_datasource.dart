import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/features/admin/domain/repositories/admin_repository.dart';

class AdminRemoteDatasource implements AdminRepository {
  final ApiClient _api;

  AdminRemoteDatasource(this._api);

  dynamic _data(Response response) {
    final body = response.data;
    return body is Map && body.containsKey('data') ? body['data'] : body;
  }

  @override
  Future<Map<String, dynamic>> dashboard() async =>
      Map<String, dynamic>.from(_data(await _api.get('/admin/dashboard')));

  @override
  Future<List<Map<String, dynamic>>> users() async =>
      List<Map<String, dynamic>>.from(
        (_data(await _api.get('/admin/users')) as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );

  @override
  Future<List<Map<String, dynamic>>> orders() async =>
      List<Map<String, dynamic>>.from(
        (_data(await _api.get('/admin/orders')) as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );

  @override
  Future<List<Map<String, dynamic>>> recipes() async {
    final response = await _api.get('/recipes/admin/all');
    return List<Map<String, dynamic>>.from(
      (response.data['data'] as List).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> settings() async =>
      Map<String, dynamic>.from(_data(await _api.get('/admin/settings')));

  @override
  Future<void> updateUser(String id, {String? role, bool? isPro}) async {
    await _api.patch(
      '/admin/users/$id',
      data: {'role': ?role, 'isPro': ?isPro},
    );
  }

  @override
  Future<void> deleteUser(String id) => _api.delete('/admin/users/$id');

  @override
  Future<void> notifyUser(String id, String message) =>
      _api.post('/admin/users/$id/notification', data: {'message': message});

  @override
  Future<void> sendRecovery(String id) =>
      _api.post('/admin/users/$id/recovery');

  @override
  Future<void> removePurchase(String userId, String recipeId) =>
      _api.delete('/admin/users/$userId/purchases/$recipeId');

  @override
  Future<void> deleteRecipe(String id) => _api.delete('/recipes/$id');

  @override
  Future<void> addRecipe(Map<String, dynamic> recipe) =>
      _api.post('/recipes', data: recipe);

  @override
  Future<void> updateRecipe(String id, Map<String, dynamic> recipe) =>
      _api.put('/recipes/$id', data: recipe);

  @override
  Future<String> uploadRecipeImage(String path) async {
    final fileName = path.split(RegExp(r'[/\\]')).last;
    final response = await _api.post(
      '/recipes/image',
      data: FormData.fromMap({
        'image': await MultipartFile.fromFile(path, filename: fileName),
      }),
    );
    return response.data['data']['image'].toString();
  }

  @override
  Future<void> broadcast(String message, {String type = 'announcement'}) =>
      _api.post('/admin/broadcast', data: {'message': message, 'type': type});

  @override
  Future<void> maintenance(bool enabled) =>
      _api.patch('/admin/settings/maintenance', data: {'enabled': enabled});

  @override
  Future<void> clearCache() => _api.post('/admin/settings/clear-cache');
}
