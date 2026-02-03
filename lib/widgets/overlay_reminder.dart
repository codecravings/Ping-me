import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:pingme/models/reminder.dart';
import 'package:pingme/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayReminderWidget extends StatefulWidget {
  const OverlayReminderWidget({super.key});

  @override
  State<OverlayReminderWidget> createState() => _OverlayReminderWidgetState();
}

class _OverlayReminderWidgetState extends State<OverlayReminderWidget> {
  Reminder? _reminder;
  Language _language = Language.english;
  String _status = 'Waiting...';

  @override
  void initState() {
    super.initState();
    _listenForData();
  }

  void _listenForData() {
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data != null && data is String) {
        try {
          final json = jsonDecode(data);
          if (json is Map<String, dynamic>) {
            if (json.containsKey('language')) {
              setState(() {
                _language = json['language'] == 'mr' ? Language.marathi : Language.english;
              });
            } else {
              setState(() {
                _reminder = Reminder.fromJson(json);
                _status = 'Reminder loaded';
              });
            }
          }
        } catch (e) {
          setState(() => _status = 'Error: $e');
        }
      }
    });
  }

  void _closeOverlay(String action) {
    setState(() => _status = 'Closing...');

    // Save to prefs first
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pending_overlay_action', jsonEncode({
        'action': action,
        'id': _reminder?.id ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
    });

    // Close overlay
    FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  _reminder?.getTitle(_language) ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _status,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _closeOverlay('done'),
                        icon: const Icon(Icons.check),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _closeOverlay('snooze'),
                        icon: const Icon(Icons.snooze),
                        label: const Text('Snooze'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
