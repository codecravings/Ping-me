import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pingme/models/reminder.dart';
import 'package:pingme/services/overlay_service.dart';
import 'package:pingme/services/background_service.dart';

class ReminderProvider extends ChangeNotifier {
  final List<Reminder> _reminders = [];
  final OverlayService _overlayService = OverlayService();
  Timer? _actionPollTimer;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<Reminder> get activeReminders =>
      _reminders.where((r) => r.isActive).toList();
  List<Reminder> get upcomingReminders => activeReminders
      .where((r) => r.scheduledTime.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

  Future<void> init() async {
    await _overlayService.init();
    await _loadReminders();
    // Reschedule all reminders on app start
    await BackgroundServiceHelper.rescheduleAllReminders();
    _listenForOverlayActions();
    _startActionPolling();
  }

  // Poll SharedPreferences for pending overlay actions (cross-isolate workaround)
  void _startActionPolling() {
    _actionPollTimer?.cancel();
    _actionPollTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      await _checkPendingOverlayAction();
    });
  }

  Future<void> _checkPendingOverlayAction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force reload to get latest data from disk
      final actionJson = prefs.getString('pending_overlay_action');

      if (actionJson != null && actionJson.isNotEmpty) {
        debugPrint('📩 Found pending action in SharedPreferences: $actionJson');

        // Clear it immediately to prevent duplicate processing
        await prefs.remove('pending_overlay_action');

        final json = jsonDecode(actionJson);
        if (json is Map<String, dynamic> && json.containsKey('action')) {
          final action = json['action'];
          final id = json['id'];

          debugPrint('🔔 Processing action: $action, ID: $id');

          // Stop sound and close overlay immediately
          debugPrint('🔇 Stopping sound and closing overlay...');
          await _overlayService.stopSound();
          await _overlayService.closeOverlay();

          // Also cancel the notification (in case sound is from there)
          await BackgroundServiceHelper.cancelNotification(id);
          debugPrint('🔇 Sound/overlay/notification stopped');

          if (action == 'done') {
            await markReminderDone(id);
          } else if (action == 'snooze') {
            await snoozeReminder(id);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking pending overlay action: $e');
    }
  }

  void _listenForOverlayActions() {
    _overlayService.overlayDataStream.listen((data) async {
      debugPrint('📩 Overlay data received via stream: $data');
      if (data != null && data is String) {
        try {
          final json = jsonDecode(data);
          if (json is Map<String, dynamic> && json.containsKey('action')) {
            final action = json['action'];
            final id = json['id'];

            debugPrint('🔔 Stream Action: $action, ID: $id');

            // Stop sound and close overlay immediately
            debugPrint('🔇 Stopping sound and closing overlay...');
            await _overlayService.stopSound();
            await _overlayService.closeOverlay();
            await BackgroundServiceHelper.cancelNotification(id);
            debugPrint('🔇 Sound/overlay/notification stopped');

            if (action == 'done') {
              await markReminderDone(id);
            } else if (action == 'snooze') {
              await snoozeReminder(id);
            }
          }
        } catch (e) {
          debugPrint('❌ Error parsing overlay data: $e');
        }
      }
    });
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders') ?? [];

    _reminders.clear();
    for (final json in remindersJson) {
      try {
        _reminders.add(Reminder.fromJson(jsonDecode(json)));
      } catch (e) {
        // Skip invalid entries
      }
    }
    notifyListeners();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        _reminders.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('reminders', remindersJson);
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    // Schedule the alarm
    await BackgroundServiceHelper.scheduleReminder(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _saveReminders();
      // Reschedule the alarm
      await BackgroundServiceHelper.cancelReminder(reminder.id);
      await BackgroundServiceHelper.scheduleReminder(reminder);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    // Cancel the alarm
    await BackgroundServiceHelper.cancelReminder(id);
    notifyListeners();
  }

  Future<void> toggleReminderActive(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
      _reminders[index] = updatedReminder;
      await _saveReminders();

      // Schedule or cancel based on active state
      if (updatedReminder.isActive) {
        await BackgroundServiceHelper.scheduleReminder(updatedReminder);
      } else {
        await BackgroundServiceHelper.cancelReminder(id);
      }
      notifyListeners();
    }
  }

  Future<void> snoozeReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final snoozeMinutes = reminder.snoozeMinutes ?? 5;
      final newTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
      final updatedReminder = reminder.copyWith(scheduledTime: newTime);
      _reminders[index] = updatedReminder;
      await _saveReminders();
      await _overlayService.closeOverlay();
      // Cancel the notification
      await BackgroundServiceHelper.cancelNotification(id);
      // Reschedule for snooze time
      await BackgroundServiceHelper.scheduleReminder(updatedReminder);
      notifyListeners();
    }
  }

  Future<void> markReminderDone(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];

      if (reminder.repeatDaily) {
        // Calculate next day's time
        final now = DateTime.now();
        DateTime nextTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminder.scheduledTime.hour,
          reminder.scheduledTime.minute,
        );
        // If today's time has passed, schedule for tomorrow
        if (nextTime.isBefore(now) || nextTime.isAtSameMomentAs(now)) {
          nextTime = nextTime.add(const Duration(days: 1));
        }

        final updatedReminder = reminder.copyWith(scheduledTime: nextTime);
        _reminders[index] = updatedReminder;
        await _saveReminders();
        await _overlayService.closeOverlay();
        // Cancel current notification and reschedule for next day
        await BackgroundServiceHelper.cancelNotification(id);
        await BackgroundServiceHelper.scheduleReminder(updatedReminder);
      } else {
        // One-time reminder: deactivate it
        _reminders[index] = reminder.copyWith(isActive: false);
        await _saveReminders();
        await _overlayService.closeOverlay();
        // Cancel the alarm and notification
        await BackgroundServiceHelper.cancelReminder(id);
      }
      notifyListeners();
    }
  }

  Future<void> showReminderNow(Reminder reminder) async {
    await _overlayService.showOverlay(reminder);
  }

  Future<void> closeOverlay() async {
    await _overlayService.closeOverlay();
  }

  @override
  void dispose() {
    _actionPollTimer?.cancel();
    _overlayService.dispose();
    super.dispose();
  }
}
