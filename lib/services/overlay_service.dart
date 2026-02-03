import 'dart:convert';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:pingme/models/reminder.dart';
import 'package:pingme/services/audio_service.dart';
import 'package:pingme/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  final AudioService _audioService = AudioService();
  bool _isOverlayActive = false;

  Future<void> init() async {
    await _audioService.init();
  }

  Future<Language> _getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt('language') ?? 0;
    return Language.values[langIndex];
  }

  Future<bool> showOverlay(Reminder reminder, {bool playSound = true}) async {
    try {
      final bool hasPermission =
          await FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        return false;
      }

      // Get current language setting
      final language = await _getCurrentLanguage();

      // Configure overlay window - full screen, user must interact
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false, // Disable drag so user must interact with buttons
        overlayTitle: "PingMe",
        overlayContent: reminder.getTitle(language),
        flag: OverlayFlag.focusPointer,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.none,
        height: WindowSize.matchParent,
        width: WindowSize.matchParent,
      );

      // Small delay before sending data
      await Future.delayed(const Duration(milliseconds: 100));

      // Send language first
      await FlutterOverlayWindow.shareData(jsonEncode({
        'language': language == Language.marathi ? 'mr' : 'en',
      }));

      // Small delay
      await Future.delayed(const Duration(milliseconds: 50));

      // Share reminder data with overlay
      await FlutterOverlayWindow.shareData(jsonEncode(reminder.toJson()));

      // Play sound only if requested (not from background service)
      if (playSound) {
        final soundSettings = await _audioService.getSelectedSound();
        final soundPath = soundSettings['path'] as String?;
        final isCustom = soundSettings['isCustom'] as bool? ?? false;

        if (soundPath != null && soundPath.isNotEmpty) {
          await _audioService.playSound(soundPath, isAsset: !isCustom);
        }
      }

      _isOverlayActive = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> closeOverlay() async {
    // Always stop sound when closing
    await _audioService.stopSound();
    if (_isOverlayActive) {
      await FlutterOverlayWindow.closeOverlay();
      _isOverlayActive = false;
    }
  }

  Future<void> stopSound() async {
    await _audioService.stopSound();
  }

  Future<void> updateOverlayData(Map<String, dynamic> data) async {
    await FlutterOverlayWindow.shareData(jsonEncode(data));
  }

  bool get isOverlayActive => _isOverlayActive;

  Stream<dynamic> get overlayDataStream =>
      FlutterOverlayWindow.overlayListener;

  Future<bool> isOverlayPermissionGranted() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  Future<bool> requestOverlayPermission() async {
    return await FlutterOverlayWindow.requestPermission() ?? false;
  }

  void dispose() {
    _audioService.dispose();
  }
}
