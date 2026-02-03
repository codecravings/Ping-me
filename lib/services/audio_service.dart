import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // Default sounds - add mp3 files to assets/sounds/ folder
  // Currently only "Silent" and custom sounds work until you add sound files
  static const List<Map<String, String>> defaultSounds = [
    {'name': 'Silent', 'path': ''},
  ];

  Future<void> init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSound(String? soundPath, {bool isAsset = true}) async {
    try {
      await stopSound();
      _isPlaying = true;

      if (soundPath == null || soundPath.isEmpty) {
        // No sound to play - silent mode or system default
        _isPlaying = false;
        return;
      } else if (isAsset) {
        await _audioPlayer.play(AssetSource(soundPath));
      } else {
        // Custom sound from device storage
        await _audioPlayer.play(DeviceFileSource(soundPath));
      }
    } catch (e) {
      _isPlaying = false;
      // Silently fail if sound file doesn't exist
    }
  }

  Future<void> stopSound() async {
    // Always try to stop, regardless of _isPlaying state
    debugPrint('🔇 AudioService.stopSound() called, isPlaying=$_isPlaying');
    try {
      await _audioPlayer.stop();
      debugPrint('🔇 AudioPlayer.stop() completed');
    } catch (e) {
      debugPrint('❌ AudioPlayer.stop() error: $e');
    }
    _isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> previewSound(String soundPath, {bool isAsset = true}) async {
    if (soundPath.isEmpty) return;

    await playSound(soundPath, isAsset: isAsset);
    // Auto stop after 3 seconds for preview
    Future.delayed(const Duration(seconds: 3), () {
      stopSound();
    });
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    _audioPlayer.dispose();
  }

  // Save selected sound preference
  Future<void> saveSelectedSound(String soundPath, bool isCustom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_sound', soundPath);
    await prefs.setBool('is_custom_sound', isCustom);
  }

  // Get selected sound preference
  Future<Map<String, dynamic>> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'path': prefs.getString('selected_sound') ?? '',
      'isCustom': prefs.getBool('is_custom_sound') ?? false,
    };
  }
}
