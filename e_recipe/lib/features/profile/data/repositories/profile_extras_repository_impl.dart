import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_extras_repository.dart';
import 'package:hive/hive.dart';

class ProfileExtrasRepositoryImpl implements ProfileExtrasRepository {
  final ApiClient _api;
  ProfileExtrasRepositoryImpl(this._api);

  Box<String> get _settings => Hive.box<String>(HiveTableConstant.sessionBox);

  @override
  Future<List<Map<String, dynamic>>> notifications() async {
    final response = await _api.get('/notifications/my');
    final body = response.data;
    final data = body is Map && body.containsKey('data') ? body['data'] : body;
    return (data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Future<void> markNotificationRead(String id) =>
      _api.patch('/notifications/$id/read');
  @override
  Future<void> markAllNotificationsRead() =>
      _api.patch('/notifications/read-all');
  @override
  Future<void> clearNotifications() => _api.delete('/notifications/clear-all');
  @override
  Future<void> resetPasswordFromNotification({
    required String notificationId,
    required String token,
    required String newPassword,
  }) => _api.patch(
    '/notifications/$notificationId/reset-password',
    data: {'token': token, 'newPassword': newPassword},
  );
  @override
  Future<Map<String, dynamic>> notificationPreferences() async {
    final response = await _api.get('/users/me/preferences');
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  @override
  Future<void> saveNotificationPreferences({
    required bool recipeUpdates,
    required bool proOffers,
  }) => _api.put(
    '/users/me/preferences',
    data: {
      'recipeUpdatesEnabled': recipeUpdates,
      'proOffersEnabled': proOffers,
    },
  );
  @override
  bool readLocalSetting(String key, bool fallback) =>
      (_settings.get(key) ?? fallback.toString()) == 'true';
  @override
  Future<void> writeLocalSetting(String key, bool value) =>
      _settings.put(key, value.toString());
}
