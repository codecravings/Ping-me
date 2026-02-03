import 'package:pingme/utils/constants.dart';

class Reminder {
  final String id;
  final String titleEn;
  final String titleMr;
  final String? descriptionEn;
  final String? descriptionMr;
  final ReminderType type;
  final String? iconPath;
  final String? imagePath;
  final String? soundPath;
  final DateTime scheduledTime;
  final int? snoozeMinutes;
  final bool isActive;
  final DateTime createdAt;
  final String? doneButtonText;
  final String? snoozeButtonText;
  final bool repeatDaily;

  Reminder({
    required this.id,
    required this.titleEn,
    required this.titleMr,
    this.descriptionEn,
    this.descriptionMr,
    required this.type,
    this.iconPath,
    this.imagePath,
    this.soundPath,
    required this.scheduledTime,
    this.snoozeMinutes = 5,
    this.isActive = true,
    DateTime? createdAt,
    this.doneButtonText,
    this.snoozeButtonText,
    this.repeatDaily = false,
  }) : createdAt = createdAt ?? DateTime.now();

  String getTitle(Language language) {
    if (language == Language.english) {
      return titleEn.isNotEmpty ? titleEn : titleMr;
    } else {
      return titleMr.isNotEmpty ? titleMr : titleEn;
    }
  }

  String? getDescription(Language language) {
    if (language == Language.english) {
      final desc = descriptionEn;
      return (desc != null && desc.isNotEmpty) ? desc : descriptionMr;
    } else {
      final desc = descriptionMr;
      return (desc != null && desc.isNotEmpty) ? desc : descriptionEn;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleMr': titleMr,
      'descriptionEn': descriptionEn,
      'descriptionMr': descriptionMr,
      'type': type.index,
      'iconPath': iconPath,
      'imagePath': imagePath,
      'soundPath': soundPath,
      'scheduledTime': scheduledTime.toIso8601String(),
      'snoozeMinutes': snoozeMinutes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'doneButtonText': doneButtonText,
      'snoozeButtonText': snoozeButtonText,
      'repeatDaily': repeatDaily,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      titleEn: json['titleEn'] ?? '',
      titleMr: json['titleMr'] ?? '',
      descriptionEn: json['descriptionEn'],
      descriptionMr: json['descriptionMr'],
      type: ReminderType.values[json['type']],
      iconPath: json['iconPath'],
      imagePath: json['imagePath'],
      soundPath: json['soundPath'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      snoozeMinutes: json['snoozeMinutes'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      doneButtonText: json['doneButtonText'],
      snoozeButtonText: json['snoozeButtonText'],
      repeatDaily: json['repeatDaily'] ?? false,
    );
  }

  Reminder copyWith({
    String? id,
    String? titleEn,
    String? titleMr,
    String? descriptionEn,
    String? descriptionMr,
    ReminderType? type,
    String? iconPath,
    String? imagePath,
    String? soundPath,
    DateTime? scheduledTime,
    int? snoozeMinutes,
    bool? isActive,
    String? doneButtonText,
    String? snoozeButtonText,
    bool? repeatDaily,
  }) {
    return Reminder(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleMr: titleMr ?? this.titleMr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionMr: descriptionMr ?? this.descriptionMr,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      imagePath: imagePath ?? this.imagePath,
      soundPath: soundPath ?? this.soundPath,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      doneButtonText: doneButtonText ?? this.doneButtonText,
      snoozeButtonText: snoozeButtonText ?? this.snoozeButtonText,
      repeatDaily: repeatDaily ?? this.repeatDaily,
    );
  }
}
