import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pingme/l10n/app_localizations.dart';
import 'package:pingme/models/reminder.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/utils/constants.dart';
import 'package:pingme/widgets/glassmorphic_card.dart';
import 'package:intl/intl.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? existingReminder;

  const AddReminderScreen({super.key, this.existingReminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEnController = TextEditingController();
  final _titleMrController = TextEditingController();
  final _doneButtonController = TextEditingController();
  final _snoozeButtonController = TextEditingController();

  ReminderType _selectedType = ReminderType.custom;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _snoozeMinutes = 5;
  bool _repeatDaily = false;
  String? _selectedEmoji;
  String? _selectedImagePath;

  // Common emojis for reminders
  static const List<String> _emojis = [
    '💊', '💉', '🩺', '❤️', '🏃', '🧘', '💪', '🥗',
    '💧', '📄', '📝', '📅', '⏰', '🔔', '✅', '⭐',
    '🎯', '📞', '💼', '🏠', '🚗', '✈️', '🛒', '💰',
    '📚', '🎓', '🎵', '🎮', '🌙', '☀️', '🌿', '🙏',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      final r = widget.existingReminder!;
      _titleEnController.text = r.titleEn;
      _titleMrController.text = r.titleMr;
      _selectedType = r.type;
      _selectedDate = r.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(r.scheduledTime);
      _snoozeMinutes = r.snoozeMinutes ?? 5;
      _repeatDaily = r.repeatDaily;
      _selectedEmoji = r.iconPath;
      _selectedImagePath = r.imagePath;
      _doneButtonController.text = r.doneButtonText ?? '';
      _snoozeButtonController.text = r.snoozeButtonText ?? '';
    }
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleMrController.dispose();
    _doneButtonController.dispose();
    _snoozeButtonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
      });
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Emoji / इमोजी निवडा',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedEmoji = null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEmoji = emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryAccent.withAlpha(51)
                          : Colors.grey.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.primaryAccent, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveReminder() {
    // Validate at least one title is provided
    final hasEnglish = _titleEnController.text.trim().isNotEmpty;
    final hasMarathi = _titleMrController.text.trim().isNotEmpty;

    if (!hasEnglish && !hasMarathi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one title (English or Marathi)')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final reminder = Reminder(
      id: widget.existingReminder?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titleEn: _titleEnController.text.trim(),
      titleMr: _titleMrController.text.trim(),
      type: _selectedType,
      iconPath: _selectedEmoji,
      imagePath: _selectedImagePath,
      scheduledTime: scheduledDateTime,
      snoozeMinutes: _snoozeMinutes,
      isActive: true,
      doneButtonText: _doneButtonController.text.trim().isEmpty
          ? null
          : _doneButtonController.text.trim(),
      snoozeButtonText: _snoozeButtonController.text.trim().isEmpty
          ? null
          : _snoozeButtonController.text.trim(),
      repeatDaily: _repeatDaily,
    );

    final reminderProvider =
        Provider.of<ReminderProvider>(context, listen: false);

    if (widget.existingReminder != null) {
      reminderProvider.updateReminder(reminder);
    } else {
      reminderProvider.addReminder(reminder);
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reminderCreated)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingReminder != null ? l10n.edit : l10n.addReminder),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B).withAlpha(128),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE0E7FF).withAlpha(128),
                  ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Emoji, Image & Type Selection Row
              Row(
                children: [
                  // Emoji Picker
                  GestureDetector(
                    onTap: _showEmojiPicker,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(26)
                            : Colors.black.withAlpha(13),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedEmoji != null
                              ? AppColors.primaryAccent
                              : AppColors.primaryAccent.withAlpha(77),
                          width: _selectedEmoji != null ? 2 : 1,
                        ),
                      ),
                      child: _selectedEmoji != null
                          ? Center(
                              child: Text(
                                _selectedEmoji!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_reaction_outlined,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                Text(
                                  'Emoji',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    onLongPress: () {
                      if (_selectedImagePath != null) {
                        setState(() => _selectedImagePath = null);
                      }
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(26)
                            : Colors.black.withAlpha(13),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedImagePath != null
                              ? AppColors.primaryAccent
                              : AppColors.primaryAccent.withAlpha(77),
                          width: _selectedImagePath != null ? 2 : 1,
                        ),
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                Text(
                                  'Image',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type Selection
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ReminderType.values.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _TypeChip(
                              type: type,
                              isSelected: _selectedType == type,
                              onTap: () => setState(() => _selectedType = type),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // English Title
              _buildSectionCard(
                icon: '🇬🇧',
                title: 'English Title',
                child: TextFormField(
                  controller: _titleEnController,
                  decoration: const InputDecoration(
                    hintText: 'Enter reminder title in English',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Marathi Title
              _buildSectionCard(
                icon: '🇮🇳',
                title: 'मराठी शीर्षक (Marathi Title)',
                child: TextFormField(
                  controller: _titleMrController,
                  decoration: const InputDecoration(
                    hintText: 'स्मरणपत्र शीर्षक मराठीत लिहा',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicCard(
                      onTap: _selectDate,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📅', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassmorphicCard(
                      onTap: _selectTime,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('⏰', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Snooze Duration
              GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('😴', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Snooze Duration / स्नूझ कालावधी',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _snoozeMinutes.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_snoozeMinutes min',
                            onChanged: (value) {
                              setState(() => _snoozeMinutes = value.round());
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_snoozeMinutes min',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.primaryAccentDark
                                  : AppColors.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Repeat Daily Toggle
              GlassmorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('🔁', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.repeatDaily,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Switch(
                      value: _repeatDaily,
                      onChanged: (value) {
                        setState(() => _repeatDaily = value);
                      },
                      activeColor: AppColors.primaryAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Custom Button Text
              GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('✏️', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Custom Button Text (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _doneButtonController,
                            decoration: InputDecoration(
                              hintText: 'Done button',
                              prefixIcon: const Icon(Icons.check_rounded, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _snoozeButtonController,
                            decoration: InputDecoration(
                              hintText: 'Snooze button',
                              prefixIcon: const Icon(Icons.snooze_rounded, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded),
                      const SizedBox(width: 8),
                      Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String icon,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(13) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ReminderType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (type) {
      case ReminderType.pill:
        return Icons.medication_rounded;
      case ReminderType.document:
        return Icons.description_rounded;
      case ReminderType.habit:
        return Icons.repeat_rounded;
      case ReminderType.custom:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor() {
    switch (type) {
      case ReminderType.pill:
        return const Color(0xFF10B981);
      case ReminderType.document:
        return const Color(0xFF3B82F6);
      case ReminderType.habit:
        return const Color(0xFF8B5CF6);
      case ReminderType.custom:
        return const Color(0xFF06B6D4);
    }
  }

  String _getLabel() {
    switch (type) {
      case ReminderType.pill:
        return 'Pill';
      case ReminderType.document:
        return 'Doc';
      case ReminderType.habit:
        return 'Habit';
      case ReminderType.custom:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(51) : Colors.grey.withAlpha(26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), color: color, size: 20),
            Text(
              _getLabel(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
