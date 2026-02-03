import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pingme/utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  Language _language = Language.english;
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedSound = '';
  bool _isCustomSound = false;
  double _volume = 0.8;

  Language get language => _language;
  ThemeMode get themeMode => _themeMode;
  String get selectedSound => _selectedSound;
  bool get isCustomSound => _isCustomSound;
  double get volume => _volume;

  Locale get locale =>
      _language == Language.english ? const Locale('en') : const Locale('mr');

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load language
    final langIndex = prefs.getInt('language') ?? 0;
    _language = Language.values[langIndex];

    // Load theme
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Load sound settings
    _selectedSound = prefs.getString('selected_sound') ?? '';
    _isCustomSound = prefs.getBool('is_custom_sound') ?? false;
    _volume = prefs.getDouble('volume') ?? 0.8;

    notifyListeners();
  }

  Future<void> setLanguage(Language language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('language', language.index);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setSound(String soundPath, bool isCustom) async {
    _selectedSound = soundPath;
    _isCustomSound = isCustom;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_sound', soundPath);
    await prefs.setBool('is_custom_sound', isCustom);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
    notifyListeners();
  }

  void toggleLanguage() {
    setLanguage(
        _language == Language.english ? Language.marathi : Language.english);
  }
}
