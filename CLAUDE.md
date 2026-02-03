# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run                      # Debug mode
flutter run --release            # Release mode

# Build
flutter build apk               # Android APK
flutter build appbundle         # Android App Bundle

# Testing
flutter test                     # Run all tests
flutter test test/widget_test.dart  # Run specific test

# Code quality
flutter analyze                  # Run Dart analyzer
```

## Architecture Overview

PingMe is a Flutter cross-platform reminder app with floating overlay functionality and glassmorphism design.

### Entry Points
- `lib/main.dart` contains two entry points: `main()` for the main app and `overlayMain()` for the overlay window

### State Management
Uses Provider pattern with ChangeNotifier:
- `ReminderProvider` - manages reminder CRUD and persistence
- `SettingsProvider` - manages app settings (language, theme, sound)

### Key Services
- `BackgroundService` - schedules reminders using Android Alarm Manager, checks reminders every minute
- `OverlayService` - manages floating overlay window with JSON-based communication
- `AudioService` - handles sound playback for reminders
- `PermissionService` - handles overlay and notification permissions

### Data Flow
1. Reminders stored as JSON in SharedPreferences via `ReminderProvider`
2. `BackgroundService` schedules alarms for active reminders
3. When triggered, either `OverlayService` shows floating window or falls back to local notification
4. Overlay communicates back to main app via JSON messages

### UI Components
- `GlassmorphicCard` - reusable glassmorphism widget with BackdropFilter
- `OverlayReminder` - the floating overlay UI with snooze/dismiss actions
- Theme definitions in `lib/theme/app_theme.dart` (Material 3 light/dark)

## Project Configuration

- **Min Android SDK:** 24
- **App ID:** com.pingme.pingme
- **Dart SDK:** ^3.10.7
- **Localization:** English and Marathi support via intl package

## Key Dependencies

- `flutter_overlay_window` - floating overlay functionality
- `android_alarm_manager_plus` - exact time scheduling
- `flutter_local_notifications` - notification fallback
- `flutter_background_service` - background task execution
- `provider` - state management
- `shared_preferences` - local persistence
- `audioplayers` - sound playback
