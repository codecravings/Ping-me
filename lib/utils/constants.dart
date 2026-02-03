import 'package:flutter/material.dart';

class AppColors {
  // Light Mode
  static const Color glassBackgroundLight = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF6366F1);
  static const Color secondaryAccent = Color(0xFF06B6D4);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color doneButton = Color(0xFF10B981);
  static const Color snoozeButton = Color(0xFF8B5CF6);
  static const Color borderGlowLight = Color(0xFFE0E7FF);

  // Dark Mode
  static const Color glassBackgroundDark = Color(0xFF0A1628);
  static const Color primaryAccentDark = Color(0xFF818CF8);
  static const Color secondaryAccentDark = Color(0xFF22D3EE);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color doneButtonDark = Color(0xFF34D399);
  static const Color snoozeButtonDark = Color(0xFFA78BFA);
  static const Color borderGlowDark = Color(0xFF312E81);
}

class AppDimensions {
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusSmall = 12.0;
  static const double backdropBlur = 25.0;
  static const double iconSizeMedium = 40.0;
  static const double iconSizeSmall = 32.0;
  static const double minOverlayWidth = 200.0;
  static const double maxOverlayWidth = 320.0;
  static const double touchTargetMin = 44.0;
}

class AppStrings {
  static const String appName = 'PingMe';
  static const String defaultLocale = 'en';
}

enum ReminderType { pill, document, habit, custom }

enum Language { english, marathi }
