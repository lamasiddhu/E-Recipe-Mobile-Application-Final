import 'package:e_recipe/features/profile/domain/repositories/profile_extras_repository.dart';

class ProfileExtrasUseCases implements ProfileExtrasRepository {
  final ProfileExtrasRepository _repository;
  ProfileExtrasUseCases(this._repository);

  @override
  Future<List<Map<String, dynamic>>> notifications() =>
      _repository.notifications();
  @override
  Future<void> markNotificationRead(String id) =>
      _repository.markNotificationRead(id);
  @override
  Future<void> markAllNotificationsRead() =>
      _repository.markAllNotificationsRead();
  @override
  Future<void> clearNotifications() => _repository.clearNotifications();
  @override
  Future<void> resetPasswordFromNotification({
    required String notificationId,
    required String token,
    required String newPassword,
  }) => _repository.resetPasswordFromNotification(
    notificationId: notificationId,
    token: token,
    newPassword: newPassword,
  );
  @override
  Future<Map<String, dynamic>> notificationPreferences() =>
      _repository.notificationPreferences();
  @override
  Future<void> saveNotificationPreferences({
    required bool recipeUpdates,
    required bool proOffers,
  }) => _repository.saveNotificationPreferences(
    recipeUpdates: recipeUpdates,
    proOffers: proOffers,
  );
  @override
  bool readLocalSetting(String key, bool fallback) =>
      _repository.readLocalSetting(key, fallback);
  @override
  Future<void> writeLocalSetting(String key, bool value) =>
      _repository.writeLocalSetting(key, value);
}
