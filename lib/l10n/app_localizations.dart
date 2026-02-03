import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'appName': 'PingMe',
      'settings': 'Settings',
      'reminders': 'Reminders',
      'addReminder': 'Add Reminder',

      // Actions
      'done': 'Done',
      'snooze': 'Snooze',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',

      // Reminder Types
      'pill': 'Pill',
      'document': 'Document',
      'habit': 'Habit',
      'custom': 'Custom',

      // Settings
      'language': 'Language',
      'english': 'English',
      'marathi': 'Marathi',
      'selectSound': 'Select Sound',
      'defaultSound': 'Default Sound',
      'customSound': 'Custom Sound',
      'chooseFile': 'Choose File',
      'theme': 'Theme',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'systemDefault': 'System Default',

      // Permissions
      'permissionRequired': 'Permission Required',
      'overlayPermissionTitle': 'Overlay Permission',
      'overlayPermissionDesc':
          'PingMe needs permission to display reminders over other apps. This allows you to see reminders no matter what app you\'re using.',
      'grantPermission': 'Grant Permission',
      'permissionDenied': 'Permission Denied',
      'permissionDeniedDesc':
          'Without overlay permission, PingMe cannot show floating reminders. Please grant permission in settings.',
      'openSettings': 'Open Settings',

      // Form
      'titleEnglish': 'Title (English)',
      'titleMarathi': 'Title (Marathi)',
      'descriptionEnglish': 'Description (English)',
      'descriptionMarathi': 'Description (Marathi)',
      'selectTime': 'Select Time',
      'selectDate': 'Select Date',
      'reminderType': 'Reminder Type',
      'snoozeDuration': 'Snooze Duration',
      'minutes': 'minutes',

      // Messages
      'reminderCreated': 'Reminder created successfully',
      'reminderDeleted': 'Reminder deleted',
      'noReminders': 'No reminders yet',
      'tapToAdd': 'Tap + to add a reminder',

      // Repeat
      'repeatDaily': 'Repeat Daily',
      'daily': 'Daily',
    },
    'mr': {
      // App
      'appName': 'पिंगमी',
      'settings': 'सेटिंग्ज',
      'reminders': 'स्मरणपत्रे',
      'addReminder': 'स्मरणपत्र जोडा',

      // Actions
      'done': 'पूर्ण',
      'snooze': 'स्नूझ',
      'cancel': 'रद्द करा',
      'save': 'जतन करा',
      'delete': 'हटवा',
      'edit': 'संपादित करा',

      // Reminder Types
      'pill': 'गोळी',
      'document': 'दस्तऐवज',
      'habit': 'सवय',
      'custom': 'सानुकूल',

      // Settings
      'language': 'भाषा',
      'english': 'इंग्रजी',
      'marathi': 'मराठी',
      'selectSound': 'आवाज निवडा',
      'defaultSound': 'डीफॉल्ट आवाज',
      'customSound': 'सानुकूल आवाज',
      'chooseFile': 'फाइल निवडा',
      'theme': 'थीम',
      'lightMode': 'लाइट मोड',
      'darkMode': 'डार्क मोड',
      'systemDefault': 'सिस्टम डीफॉल्ट',

      // Permissions
      'permissionRequired': 'परवानगी आवश्यक',
      'overlayPermissionTitle': 'ओव्हरले परवानगी',
      'overlayPermissionDesc':
          'पिंगमीला इतर ॲप्सवर स्मरणपत्रे दाखवण्यासाठी परवानगी आवश्यक आहे. यामुळे तुम्ही कोणतेही ॲप वापरत असाल तरी स्मरणपत्रे पाहू शकता.',
      'grantPermission': 'परवानगी द्या',
      'permissionDenied': 'परवानगी नाकारली',
      'permissionDeniedDesc':
          'ओव्हरले परवानगीशिवाय, पिंगमी फ्लोटिंग स्मरणपत्रे दाखवू शकत नाही. कृपया सेटिंग्जमध्ये परवानगी द्या.',
      'openSettings': 'सेटिंग्ज उघडा',

      // Form
      'titleEnglish': 'शीर्षक (इंग्रजी)',
      'titleMarathi': 'शीर्षक (मराठी)',
      'descriptionEnglish': 'वर्णन (इंग्रजी)',
      'descriptionMarathi': 'वर्णन (मराठी)',
      'selectTime': 'वेळ निवडा',
      'selectDate': 'तारीख निवडा',
      'reminderType': 'स्मरणपत्र प्रकार',
      'snoozeDuration': 'स्नूझ कालावधी',
      'minutes': 'मिनिटे',

      // Messages
      'reminderCreated': 'स्मरणपत्र यशस्वीरित्या तयार झाले',
      'reminderDeleted': 'स्मरणपत्र हटवले',
      'noReminders': 'अद्याप स्मरणपत्रे नाहीत',
      'tapToAdd': 'स्मरणपत्र जोडण्यासाठी + वर टॅप करा',

      // Repeat
      'repeatDaily': 'रोज पुनरावृत्ती',
      'daily': 'रोज',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for common strings
  String get appName => translate('appName');
  String get settings => translate('settings');
  String get reminders => translate('reminders');
  String get addReminder => translate('addReminder');
  String get done => translate('done');
  String get snooze => translate('snooze');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get language => translate('language');
  String get english => translate('english');
  String get marathi => translate('marathi');
  String get selectSound => translate('selectSound');
  String get defaultSound => translate('defaultSound');
  String get customSound => translate('customSound');
  String get chooseFile => translate('chooseFile');
  String get theme => translate('theme');
  String get lightMode => translate('lightMode');
  String get darkMode => translate('darkMode');
  String get systemDefault => translate('systemDefault');
  String get permissionRequired => translate('permissionRequired');
  String get overlayPermissionTitle => translate('overlayPermissionTitle');
  String get overlayPermissionDesc => translate('overlayPermissionDesc');
  String get grantPermission => translate('grantPermission');
  String get permissionDenied => translate('permissionDenied');
  String get permissionDeniedDesc => translate('permissionDeniedDesc');
  String get openSettings => translate('openSettings');
  String get titleEnglish => translate('titleEnglish');
  String get titleMarathi => translate('titleMarathi');
  String get descriptionEnglish => translate('descriptionEnglish');
  String get descriptionMarathi => translate('descriptionMarathi');
  String get selectTime => translate('selectTime');
  String get selectDate => translate('selectDate');
  String get reminderType => translate('reminderType');
  String get snoozeDuration => translate('snoozeDuration');
  String get minutes => translate('minutes');
  String get reminderCreated => translate('reminderCreated');
  String get reminderDeleted => translate('reminderDeleted');
  String get noReminders => translate('noReminders');
  String get tapToAdd => translate('tapToAdd');
  String get pill => translate('pill');
  String get document => translate('document');
  String get habit => translate('habit');
  String get custom => translate('custom');
  String get repeatDaily => translate('repeatDaily');
  String get daily => translate('daily');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
