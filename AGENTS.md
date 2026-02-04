# PingMe - AI Agent Guide

## Project Overview

PingMe is a **Flutter cross-platform reminder app** with a focus on **floating overlay functionality** and **glassmorphism design**. The app displays reminders as floating windows over other apps, making it ideal for medication reminders, document submissions, habit tracking, and custom alerts.

### Key Features
- **Floating Overlay Reminders**: Shows reminders over other apps using system alert window permission
- **Bilingual Support**: English and Marathi (मराठी) localization
- **Glassmorphism UI**: Modern frosted-glass design with backdrop blur effects
- **Background Scheduling**: Uses Android Alarm Manager for exact-time reminders
- **Snooze & Done Actions**: Interactive overlay with customizable actions
- **Daily Repeating Reminders**: Support for recurring daily reminders
- **Custom Sounds**: Option to use custom audio files for reminders
- **Theme Support**: Light, dark, and system-default themes

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.10.7+ |
| Language | Dart |
| State Management | Provider (ChangeNotifier pattern) |
| Local Persistence | SharedPreferences |
| Background Execution | `android_alarm_manager_plus`, `flutter_background_service` |
| Overlay Windows | `flutter_overlay_window` |
| Notifications | `flutter_local_notifications` |
| Audio Playback | `audioplayers` |
| Permissions | `permission_handler` |
| File Picker | `file_picker` |
| Localization | `intl`, custom `AppLocalizations` |

### Minimum Requirements
- **Android SDK**: 24 (Android 7.0+)
- **Dart SDK**: ^3.10.7
- **App ID**: `com.pingme.pingme`

---

## Project Structure

```
lib/
├── main.dart                      # App entry points (main & overlayMain)
├── l10n/
│   └── app_localizations.dart     # English & Marathi translations
├── models/
│   └── reminder.dart              # Reminder data model with JSON serialization
├── providers/
│   ├── reminder_provider.dart     # Reminder CRUD, scheduling, overlay actions
│   └── settings_provider.dart     # Language, theme, sound preferences
├── screens/
│   ├── home_screen.dart           # Reminder list with glassmorphic cards
│   ├── add_reminder_screen.dart   # Create/edit reminders (bilingual form)
│   ├── settings_screen.dart       # Language, theme, sound settings
│   └── permission_screen.dart     # Overlay & battery optimization setup
├── services/
│   ├── background_service.dart    # Alarm scheduling, notification fallback
│   ├── overlay_service.dart       # Floating window management
│   ├── audio_service.dart         # Sound playback (asset & custom files)
│   └── permission_service.dart    # Permission checking & requests
├── theme/
│   └── app_theme.dart             # Material 3 light/dark themes
├── utils/
│   └── constants.dart             # Colors, dimensions, enums (ReminderType, Language)
└── widgets/
    ├── glassmorphic_card.dart     # Reusable frosted-glass container widget
    └── overlay_reminder.dart      # Overlay window UI (Done/Snooze buttons)
```

---

## Build and Development Commands

```bash


---

## Architecture Overview

### Entry Points

The app has **two entry points** defined in `lib/main.dart`:

1. **`main()`** - Standard Flutter app entry
   - Initializes background services
   - Sets up Provider state management
   - Shows permission screen or home screen based on overlay permission

2. **`overlayMain()`** (annotated with `@pragma("vm:entry-point")`)
   - Separate entry point for the floating overlay window
   - Runs in an isolated context when overlay is displayed
   - Listens for reminder data via `FlutterOverlayWindow.overlayListener`

### State Management

Uses **Provider** with `ChangeNotifier`:

- **`ReminderProvider`** (`lib/providers/reminder_provider.dart`)
  - Manages reminder CRUD operations
  - Persists to SharedPreferences as JSON
  - Schedules/cancels alarms via `BackgroundServiceHelper`
  - Listens for overlay actions (Done/Snooze) via polling mechanism
  - Handles snooze logic and daily repeat scheduling

- **`SettingsProvider`** (`lib/providers/settings_provider.dart`)
  - Language preference (English/Marathi)
  - Theme mode (System/Light/Dark)
  - Custom sound selection and volume

### Data Flow

```
1. User creates reminder → ReminderProvider.addReminder()
2. Reminder saved to SharedPreferences as JSON list
3. BackgroundServiceHelper.scheduleReminder() sets Android Alarm
4. At trigger time:
   a. onAlarmFired callback executes
   b. Notification shown (with fullScreenIntent)
   c. Overlay window displayed via flutter_overlay_window
5. User taps Done/Snooze in overlay:
   a. Action written to SharedPreferences as 'pending_overlay_action'
   b. Overlay closes
   c. ReminderProvider polls and processes action
   d. Reminder marked done OR rescheduled for snooze time
```

### Key Services

- **`BackgroundServiceHelper`** (`lib/services/background_service.dart`)
  - Top-level functions marked with `@pragma('vm:entry-point')` for background execution
  - `onBackgroundServiceStart`: Runs every minute to check for reminders
  - `onAlarmFired`: Triggered by AlarmManager at exact time
  - `triggerReminder`: Shows notification + overlay
  - Prevents duplicate triggers using `_triggeredReminders` Set

- **`OverlayService`** (`lib/services/overlay_service.dart`)
  - Singleton pattern
  - Manages overlay window show/close
  - Handles sound playback in overlay context
  - Streams data from overlay via `overlayDataStream`

- **`AudioService`** (`lib/services/audio_service.dart`)
  - Singleton using `AudioPlayer`
  - Supports asset sounds and custom device files
  - Auto-stops after 3 seconds for previews

---

## Code Style Guidelines

### Dart/Flutter Conventions

- Follows `package:flutter_lints/flutter.yaml` (defined in `analysis_options.yaml`)
- Use `const` constructors where possible
- Prefer single quotes for strings (not enforced)
- Use trailing commas for multi-line parameters

### Naming Conventions

```dart
// Classes: PascalCase
class ReminderProvider extends ChangeNotifier { }

// Files: snake_case
reminder_provider.dart

// Private members: leading underscore
String _selectedSound = '';

// Enums: PascalCase for type, camelCase for values
enum ReminderType { pill, document, habit, custom }

// Constants: static const with descriptive names
static const Color primaryAccent = Color(0xFF6366F1);
```

### Widget Structure

```dart
// Prefer StatelessWidget where possible
class HomeScreen extends StatelessWidget { }

// Use Consumer for Provider access
Consumer2<ReminderProvider, SettingsProvider>(
  builder: (context, reminderProvider, settingsProvider, _) {
    return /* widget */;
  },
)

// Private widget classes for file-local widgets
class _ReminderCard extends StatelessWidget { }
```

### Glassmorphism Pattern

The app uses a consistent glassmorphism design:

```dart
// GlassmorphicCard wraps content with backdrop blur
GlassmorphicCard(
  child: /* content */,
  onTap: () { },  // Optional tap handler
)

// Colors adapt to theme
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark 
    ? AppColors.glassBackgroundDark.withOpacity(0.3)
    : AppColors.glassBackgroundLight.withOpacity(0.15);
```

---

## Testing Instructions

### Current Test Coverage

Only basic widget test exists in `test/widget_test.dart`:

```dart
void main() {
  testWidgets('PingMe app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const PingMeApp());
    expect(find.text('PingMe'), findsWidgets);
  });
}
```

### Testing Recommendations

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Integration testing requires:
# - Android emulator or device
# - Overlay permission manually granted
# - Battery optimization disabled for background tests
```

### Manual Testing Checklist

1. **Overlay Permission Flow**
   - Fresh install should show permission screen
   - Grant overlay permission → navigates to home
   - Deny → stays on permission screen

2. **Reminder Creation**
   - Create reminder with English title only
   - Create reminder with Marathi title only
   - Create reminder with both languages
   - Select emoji and verify display
   - Pick custom image and verify display

3. **Reminder Triggering**
   - Set reminder for 1 minute in future
   - Close app → verify overlay appears
   - Test Done button → reminder deactivated
   - Test Snooze button → reminder rescheduled

4. **Daily Repeat**
   - Create daily repeating reminder
   - Mark Done → verify rescheduled for next day

5. **Background Behavior**
   - Swipe away app from recents
   - Verify reminder still triggers
   - Reboot device → verify alarms rescheduled

---

## Platform-Specific Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)

Critical permissions and services:

```xml
<!-- Required Permissions -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- Services -->
<service android:name="flutter.overlay.window.flutter_overlay_window.OverlayService" ... />
<service android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmService" ... />

<!-- Boot Receiver for rescheduling after reboot -->
<receiver android:name="dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver" ...>
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

### OEM-Specific Considerations

Some Android OEMs (Xiaomi, Oppo, Vivo, Realme) aggressively kill background apps:

- App requests battery optimization exemption
- Permission screen includes autostart instructions
- Users may need to manually enable "Autostart" in device settings

---

## Assets

```
assets/
├── icons/          # App icons (currently empty)
└── sounds/         # Default reminder sounds (currently empty)
```

To add default sounds:
1. Add MP3 files to `assets/sounds/`
2. Update `pubspec.yaml` assets section
3. Update `AudioService.defaultSounds` list

---

## Localization

Translation files are in `lib/l10n/app_localizations.dart` (custom implementation, not ARB files).

**Supported languages:**
- English (`en`) - Primary
- Marathi (`mr`) - Secondary

**Adding new strings:**
1. Add to `_localizedValues['en']` map
2. Add to `_localizedValues['mr']` map
3. Add getter method

---

## Security Considerations

1. **Overlay Permission**: Requires `SYSTEM_ALERT_WINDOW` - users must explicitly grant
2. **Storage Access**: Only used for custom sound/image selection via file picker
3. **Data Storage**: All data stored locally in SharedPreferences (no cloud sync)
4. **Background Execution**: Uses foreground service for reliability
5. **Exact Alarms**: Requires `SCHEDULE_EXACT_ALARM` permission (Android 12+)

---

## Common Issues & Debugging

### Overlay not showing
- Check `SYSTEM_ALERT_WINDOW` permission granted
- Verify battery optimization disabled
- Check logcat for `flutter_overlay_window` errors

### Reminders not triggering
- Verify `SCHEDULE_EXACT_ALARM` permission (Android 12+)
- Check if device has custom battery saver
- Review `BackgroundServiceHelper.checkReminders()` logs

### Sound not playing
- Custom sounds require storage permission
- Asset sounds must exist in `assets/sounds/`
- Check `AudioPlayer` exception handling

### Cross-isolate communication
- Main app and overlay run in different isolates
- Communication via SharedPreferences (not direct method calls)
- `pending_overlay_action` key used for action passing
