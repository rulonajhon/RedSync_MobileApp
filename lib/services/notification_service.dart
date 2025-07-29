import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data safely
    try {
      tz.initializeTimeZones();
    } catch (e) {
      print('Warning: Could not initialize timezone data: $e');
      // Continue without timezone support for basic functionality
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      try {
        // Request notification permission
        final bool? notificationGranted = await androidImplementation
            .requestNotificationsPermission();

        // Request exact alarm permission for Android 12+
        final bool? exactAlarmGranted = await androidImplementation
            .requestExactAlarmsPermission();

        print('Notification permission granted: $notificationGranted');
        print('Exact alarm permission granted: $exactAlarmGranted');

        // Both permissions are needed for scheduled notifications to work properly
        return (notificationGranted ?? false) && (exactAlarmGranted ?? true);
      } catch (e) {
        print('Error requesting permissions: $e');
        return false;
      }
    }

    // For iOS, we'll handle permissions differently
    return true; // Simplified for now
  }

  Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      final tzDateTime = _convertToTZDateTime(scheduledTime);
      print('Scheduling notification ID $id for $tzDateTime');
      print('Current time: ${DateTime.now()}');
      print(
        'Time difference: ${scheduledTime.difference(DateTime.now()).inMinutes} minutes',
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      print('Notification scheduled successfully!');
    } catch (e) {
      print('Error scheduling medication reminder: $e');
      rethrow;
    }
  }

  Future<void> scheduleRepeatingMedicationReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      // Calculate the next occurrence of the specified time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      }

      final tzDateTime = _convertToTZDateTime(scheduledDate);
      print(
        'Scheduling repeating notification ID $id for $tzDateTime with interval $repeatInterval',
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents:
            DateTimeComponents.time, // This makes it repeat daily
      );

      print('Repeating notification scheduled successfully!');
    } catch (e) {
      print('Error scheduling repeating medication reminder: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Convert DateTime to TZDateTime (using local timezone)
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    try {
      // First try to get the local timezone
      tz.Location? location;
      try {
        location = tz.local;
      } catch (e) {
        print('Warning: Could not get local timezone, using UTC: $e');
        location = tz.UTC;
      }

      // Convert to TZDateTime
      final tzDateTime = tz.TZDateTime.from(dateTime, location);
      print(
        'Converted DateTime $dateTime to TZDateTime $tzDateTime in timezone ${location.name}',
      );
      return tzDateTime;
    } catch (e) {
      print('Error: Timezone conversion failed completely: $e');
      // As a last resort, create a TZDateTime in UTC
      return tz.TZDateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );
    }
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Test notification to verify notifications are working
  Future<void> showTestNotification() async {
    await showImmediateNotification(
      id: 999,
      title: 'Test Notification',
      body:
          'This is a test notification to verify the notification system is working.',
      payload: 'test_notification',
    );
  }

  // Schedule a test notification for 5 seconds from now
  Future<void> scheduleTestNotification() async {
    final scheduledTime = DateTime.now().add(Duration(seconds: 5));

    print('Scheduling test notification for: $scheduledTime');
    print('Current time: ${DateTime.now()}');

    await scheduleMedicationReminder(
      id: 998,
      title: 'Test Scheduled Notification',
      body: 'This test notification was scheduled for 5 seconds ago.',
      scheduledTime: scheduledTime,
      payload: 'test_scheduled_notification',
    );

    // Check pending notifications
    final pendingNotifications = await getPendingNotifications();
    print('Total pending notifications: ${pendingNotifications.length}');
    for (final notification in pendingNotifications) {
      print(
        'Pending notification: ID ${notification.id}, title: ${notification.title}',
      );
    }
  }

  // Get all pending notifications for debugging
  Future<void> debugPendingNotifications() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      print('=== DEBUG: Pending Notifications ===');
      print('Total count: ${pendingNotifications.length}');
      for (final notification in pendingNotifications) {
        print('ID: ${notification.id}');
        print('Title: ${notification.title}');
        print('Body: ${notification.body}');
        print('Payload: ${notification.payload}');
        print('---');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error getting pending notifications: $e');
    }
  }
}
