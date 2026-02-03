import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/l10n/app_localizations.dart';
import 'package:pingme/models/reminder.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/providers/settings_provider.dart';
import 'package:pingme/screens/add_reminder_screen.dart';
import 'package:pingme/screens/settings_screen.dart';
import 'package:pingme/utils/constants.dart';
import 'package:pingme/widgets/glassmorphic_card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          // Language toggle
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return TextButton.icon(
                onPressed: settings.toggleLanguage,
                icon: const Icon(Icons.language),
                label: Text(
                  settings.language == Language.english ? 'EN' : 'MR',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B).withOpacity(0.5),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE0E7FF).withOpacity(0.5),
                  ],
          ),
        ),
        child: Consumer2<ReminderProvider, SettingsProvider>(
          builder: (context, reminderProvider, settingsProvider, _) {
            final reminders = reminderProvider.reminders;

            if (reminders.isEmpty) {
              return _buildEmptyState(context, l10n, isDark);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return _ReminderCard(
                  reminder: reminders[index],
                  language: settingsProvider.language,
                  onTest: () {
                    reminderProvider.showReminderNow(reminders[index]);
                  },
                  onDelete: () {
                    reminderProvider.deleteReminder(reminders[index].id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.reminderDeleted)),
                    );
                  },
                  onToggle: () {
                    reminderProvider.toggleReminderActive(reminders[index].id);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReminderScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addReminder),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 50,
                color: isDark
                    ? AppColors.primaryAccentDark
                    : AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noReminders,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapToAdd,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final Language language;
  final VoidCallback onTest;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ReminderCard({
    required this.reminder,
    required this.language,
    required this.onTest,
    required this.onDelete,
    required this.onToggle,
  });

  IconData _getIconForType(ReminderType type) {
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

  Color _getColorForType(ReminderType type) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _getColorForType(reminder.type);
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: reminder.isActive ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(reminder.type),
                    color: iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.getTitle(language),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${timeFormat.format(reminder.scheduledTime)} - ${dateFormat.format(reminder.scheduledTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (reminder.repeatDaily) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: iconColor,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle switch
                Switch(
                  value: reminder.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: iconColor,
                ),
              ],
            ),
            if (reminder.getDescription(language) != null) ...[
              const SizedBox(height: 8),
              Text(
                reminder.getDescription(language)!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTest,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Test'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(color: iconColor.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
