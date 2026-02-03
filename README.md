# 💊 PingMe

> *Never miss a reminder, even when you're busy on WhatsApp*

**PingMe** is a beautiful floating reminder app built with Flutter that displays reminders as overlays on top of any app — even when your phone is locked! 

## 💡 Why I Built This

My mother often forgets to take her pills while chatting on WhatsApp or browsing other apps. Regular notifications get buried or dismissed accidentally. **PingMe** solves this by showing persistent floating reminders that stay visible until acknowledged — ensuring important tasks are never forgotten, no matter what app is open.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔮 **Floating Overlay** | Reminders appear on top of any app, even when locked |
| 💊 **Medicine Reminders** | Special mode for pill/medication tracking |
| 📝 **Custom Reminders** | Documents, habits, or anything you need to remember |
| 🔊 **Custom Sounds** | Add your own audio alerts for each reminder |
| 🖼️ **Visual Reminders** | Attach images to make reminders more recognizable |
| ⏰ **Snooze** | Easy snooze with customizable duration |
| 🔄 **Daily Repeat** | Set reminders to repeat every day |
| 🌐 **Bilingual** | English & Marathi language support |
| 🎨 **Glassmorphism UI** | Modern, beautiful design with blur effects |
| 🌙 **Dark Mode** | Easy on the eyes, day or night |

## 📱 Screenshots

*Coming soon...* (Add your screenshots here!)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.10.7
- Android SDK 24+

### Installation

```bash
# Clone the repo
git clone https://github.com/codecravings/Ping-me.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Permissions
The app requires:
- **Display over other apps** - For floating overlay functionality
- **Notifications** - For reminder alerts
- **Alarm access** - For exact time scheduling

## 🛠️ Building

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle
```

## 📋 Tech Stack

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **flutter_overlay_window** - Floating overlay functionality
- **android_alarm_manager_plus** - Exact alarm scheduling
- **flutter_local_notifications** - Notification fallback
- **audioplayers** - Custom sound playback
- **shared_preferences** - Local data persistence

## 🤝 Contributing

Feel free to fork this project and submit pull requests! Whether it's bug fixes, new features, or translations — all contributions are welcome.

## 📄 License

This project is open source. Feel free to use it for personal or educational purposes.

---

Made with 💙 for my mother, and everyone who needs a little help remembering.

*Stay healthy, stay reminded!* 🌟
