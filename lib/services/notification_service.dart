import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event_model.dart';
import 'db_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize the notification service
  static Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
    // You can implement navigation logic here
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (!_initialized) await init();

    bool? result = false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      result = await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    return result ?? false;
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();
    if (!DatabaseService.getNotificationsEnabled()) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'countease_channel',
          'CountEase Notifications',
          channelDescription: 'Notifications for countdown events',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification for a specific date and time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await init();
    if (!DatabaseService.getNotificationsEnabled()) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'countease_channel',
      'CountEase Notifications',
      channelDescription: 'Notifications for countdown events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

    // Schedule notifications for an event
  static Future<void> scheduleEventNotifications(Event event) async {
    if (!event.notificationEnabled) return;

    final eventId = event.id.hashCode;
    DateTime targetDate = event.eventDate;

    // For yearly events, calculate next occurrence if needed
    if (event.repeatYearly) {
      final now = DateTime.now();
      if (targetDate.isBefore(now)) {
        targetDate = DateTime(now.year + 1, targetDate.month, targetDate.day);
      }
    }

    // Cancel existing notifications for this event
    await cancelEventNotifications(event.id);

    // Don't schedule if the event has already passed (and it's not yearly)
    if (targetDate.isBefore(DateTime.now()) && !event.repeatYearly) {
      return;
    }

    // Schedule notification on the event day (9 AM)
    final eventDayNotification = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      9, // 9 AM
    );

    if (eventDayNotification.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: eventId,
        title: '${event.typeEmoji} ${event.title}',
        body: 'Today is the day! ${event.title}',
        scheduledDate: eventDayNotification,
        payload: 'event_${event.id}',
      );
    }

    // Schedule notification 1 day before (6 PM)
    final oneDayBefore = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day - 1,
      18, // 6 PM
    );

    if (oneDayBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: eventId + 1,
        title: '${event.typeEmoji} ${event.title}',
        body: 'Tomorrow is ${event.title}! Only 1 day left.',
        scheduledDate: oneDayBefore,
        payload: 'event_${event.id}',
      );
    }

    // Schedule notification 1 week before (10 AM)
    final oneWeekBefore = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day - 7,
      10, // 10 AM
    );

    if (oneWeekBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: eventId + 2,
        title: '${event.typeEmoji} ${event.title}',
        body: '${event.title} is coming up in 1 week!',
        scheduledDate: oneWeekBefore,
        payload: 'event_${event.id}',
      );
    }

    // For yearly events, schedule next year's notifications
    if (event.repeatYearly) {
      final nextYear = DateTime(
        targetDate.year + 1,
        targetDate.month,
        targetDate.day,
      );

      final nextYearEvent = event.copyWith(eventDate: nextYear);

      // Schedule recursively for next year (but only if it's reasonable - not too far)
      if (nextYear.difference(DateTime.now()).inDays < 400) {
        await scheduleEventNotifications(nextYearEvent);
      }
    }
  }

  // Cancel notifications for a specific event
  static Future<void> cancelEventNotifications(String eventId) async {
    final id = eventId.hashCode;
    await _notifications.cancel(id);
    await _notifications.cancel(id + 1);
    await _notifications.cancel(id + 2);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Schedule notifications for all events
  static Future<void> scheduleAllEventNotifications() async {
    final events = DatabaseService.getAllEvents();
    for (final event in events) {
      await scheduleEventNotifications(event);
    }
  }

  // Show test notification
  static Future<void> showTestNotification() async {
    await showNotification(
      id: 999999,
      title: 'Test Notification',
      body: 'CountEase notifications are working correctly!',
      payload: 'test',
    );
  }

  // Helper method to create notification channels (Android)
  static Future<void> createNotificationChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'countease_channel',
        'CountEase Notifications',
        description: 'Notifications for countdown events',
        importance: Importance.high,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  // Check if notifications are enabled on the device level
  static Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // Assume enabled for other platforms
  }
}
