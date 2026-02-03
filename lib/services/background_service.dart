import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notif;
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:pingme/models/reminder.dart';

// Top-level callback for background service - MUST be top-level
@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Check reminders every minute
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    await BackgroundServiceHelper.checkReminders();
  });
}

// Top-level callback for alarm manager - MUST be top-level
@pragma('vm:entry-point')
Future<void> onAlarmFired(int id, Map<String, dynamic> params) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final reminder = Reminder.fromJson(params);
    await BackgroundServiceHelper.triggerReminder(reminder);
  } catch (e) {
    // Handle error
  }
}

class BackgroundServiceHelper {
  static final notif.FlutterLocalNotificationsPlugin _notifications =
      notif.FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize alarm manager
    await AndroidAlarmManager.initialize();

    // Initialize notifications
    const androidSettings = notif.AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = notif.InitializationSettings(android: androidSettings);
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request notification permission
    await _notifications
        .resolvePlatformSpecificImplementation<
            notif.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Initialize background service
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onBackgroundServiceStart,
        isForegroundMode: false,
        autoStart: true,
        autoStartOnBoot: true,
      ),
    );
  }

  static void _onNotificationTap(notif.NotificationResponse response) {
    // Handle notification tap - could open app
  }

  // Track triggered reminders to prevent duplicates
  static final Set<String> _triggeredReminders = {};

  static Future<void> checkReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('reminders') ?? [];
      final now = DateTime.now();

      for (final json in remindersJson) {
        try {
          final reminder = Reminder.fromJson(jsonDecode(json));
          if (!reminder.isActive) continue;

          // Create unique key for this reminder at this minute
          final triggerKey = '${reminder.id}_${now.year}${now.month}${now.day}${now.hour}${now.minute}';

          // Skip if already triggered
          if (_triggeredReminders.contains(triggerKey)) continue;

          final diff = reminder.scheduledTime.difference(now).inSeconds;
          // Trigger if within 60 seconds of scheduled time
          if (diff >= -60 && diff <= 60) {
            _triggeredReminders.add(triggerKey);
            // Clean old entries (keep only last 100)
            if (_triggeredReminders.length > 100) {
              _triggeredReminders.remove(_triggeredReminders.first);
            }
            await triggerReminder(reminder);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> triggerReminder(Reminder reminder) async {
    // Show notification with full-screen intent (wakes device)
    await _showNotification(reminder);

    // Try to show overlay (without sound - notification handles sound)
    try {
      await overlay.FlutterOverlayWindow.showOverlay(
        enableDrag: false, // Disable drag so user must interact with buttons
        overlayTitle: "PingMe Reminder",
        overlayContent: reminder.titleEn.isNotEmpty ? reminder.titleEn : reminder.titleMr,
        flag: overlay.OverlayFlag.focusPointer,
        visibility: overlay.NotificationVisibility.visibilityPublic,
        positionGravity: overlay.PositionGravity.none,
        height: overlay.WindowSize.matchParent,
        width: overlay.WindowSize.matchParent,
      );

      // Send reminder data to overlay
      await Future.delayed(const Duration(milliseconds: 200));
      await overlay.FlutterOverlayWindow.shareData(jsonEncode(reminder.toJson()));
    } catch (e) {
      // Overlay might fail if permission not granted
      debugPrint('Overlay error: $e');
    }
  }

  static Future<void> _showNotification(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt('language') ?? 0;
    final isMarathi = langIndex == 1;

    final title = isMarathi ? reminder.titleMr : reminder.titleEn;

    const androidDetails = notif.AndroidNotificationDetails(
      'pingme_reminders',
      'PingMe Reminders',
      channelDescription: 'Reminder notifications from PingMe',
      importance: notif.Importance.max,
      priority: notif.Priority.high,
      fullScreenIntent: true,
      category: notif.AndroidNotificationCategory.alarm,
      visibility: notif.NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      ongoing: true, // Cannot be dismissed by swiping
      autoCancel: false, // Don't auto-cancel when tapped
    );

    const details = notif.NotificationDetails(android: androidDetails);

    await _notifications.show(
      reminder.id.hashCode,
      'PingMe Reminder',
      title,
      details,
      payload: reminder.id,
    );
  }

  /// Schedule a specific reminder alarm
  static Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isActive) return;

    final now = DateTime.now();
    if (reminder.scheduledTime.isBefore(now)) return;

    // Cancel any existing alarm for this reminder
    await AndroidAlarmManager.cancel(reminder.id.hashCode);

    // Schedule new alarm
    await AndroidAlarmManager.oneShotAt(
      reminder.scheduledTime,
      reminder.id.hashCode,
      onAlarmFired,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: reminder.toJson(),
    );
  }

  /// Cancel a reminder alarm
  static Future<void> cancelReminder(String reminderId) async {
    await AndroidAlarmManager.cancel(reminderId.hashCode);
    // Also cancel the notification
    await _notifications.cancel(reminderId.hashCode);
  }

  /// Cancel notification for a reminder
  static Future<void> cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  /// Reschedule all active reminders (call on app start and after boot)
  static Future<void> rescheduleAllReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('reminders') ?? [];

      for (final json in remindersJson) {
        try {
          final reminder = Reminder.fromJson(jsonDecode(json));
          if (reminder.isActive &&
              reminder.scheduledTime.isAfter(DateTime.now())) {
            await scheduleReminder(reminder);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
