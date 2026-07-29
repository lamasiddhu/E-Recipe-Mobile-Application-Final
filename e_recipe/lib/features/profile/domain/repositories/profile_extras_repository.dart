abstract interface class ProfileExtrasRepository {
  Future<List<Map<String, dynamic>>> notifications();
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead();
  Future<void> clearNotifications();
  Future<void> resetPasswordFromNotification({
    required String notificationId,
    required String token,
    required String newPassword,
  });
  Future<Map<String, dynamic>> notificationPreferences();
  Future<void> saveNotificationPreferences({
    required bool recipeUpdates,
    required bool proOffers,
  });
  bool readLocalSetting(String key, bool fallback);
  Future<void> writeLocalSetting(String key, bool value);
}
