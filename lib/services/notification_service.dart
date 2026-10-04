class NotificationService {
  static Future<void> initialize() async {}

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {}

  static Future<void> cancelAll() async {}

  static Future<void> scheduleReminder(dynamic reminder) async {}

  static Future<void> cancelReminder(int id) async {}
}
