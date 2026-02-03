import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pingme/l10n/app_localizations.dart';
import 'package:pingme/providers/settings_provider.dart';
import 'package:pingme/services/audio_service.dart';
import 'package:pingme/utils/constants.dart';
import 'package:pingme/widgets/glassmorphic_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  @override
  void dispose() {
    _audioService.stopSound();
    super.dispose();
  }

  Future<void> _pickCustomSound(SettingsProvider settings) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await settings.setSound(path, true);
        _audioService.previewSound(path, isAsset: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick audio file')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Language Section
                _SectionHeader(title: l10n.language),
                const SizedBox(height: 8),
                GlassmorphicCard(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        title: l10n.english,
                        trailing: Radio<Language>(
                          value: Language.english,
                          groupValue: settings.language,
                          onChanged: (value) {
                            if (value != null) settings.setLanguage(value);
                          },
                        ),
                        onTap: () => settings.setLanguage(Language.english),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: l10n.marathi,
                        trailing: Radio<Language>(
                          value: Language.marathi,
                          groupValue: settings.language,
                          onChanged: (value) {
                            if (value != null) settings.setLanguage(value);
                          },
                        ),
                        onTap: () => settings.setLanguage(Language.marathi),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Theme Section
                _SectionHeader(title: l10n.theme),
                const SizedBox(height: 8),
                GlassmorphicCard(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.brightness_auto_rounded,
                        title: l10n.systemDefault,
                        trailing: Radio<ThemeMode>(
                          value: ThemeMode.system,
                          groupValue: settings.themeMode,
                          onChanged: (value) {
                            if (value != null) settings.setThemeMode(value);
                          },
                        ),
                        onTap: () => settings.setThemeMode(ThemeMode.system),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.light_mode_rounded,
                        title: l10n.lightMode,
                        trailing: Radio<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: settings.themeMode,
                          onChanged: (value) {
                            if (value != null) settings.setThemeMode(value);
                          },
                        ),
                        onTap: () => settings.setThemeMode(ThemeMode.light),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        title: l10n.darkMode,
                        trailing: Radio<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: settings.themeMode,
                          onChanged: (value) {
                            if (value != null) settings.setThemeMode(value);
                          },
                        ),
                        onTap: () => settings.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Sound Section
                _SectionHeader(title: l10n.selectSound),
                const SizedBox(height: 8),
                GlassmorphicCard(
                  child: Column(
                    children: [
                      // Default sounds
                      ...AudioService.defaultSounds.map((sound) {
                        final isSelected = !settings.isCustomSound &&
                            settings.selectedSound == sound['path'];
                        return Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.music_note_rounded,
                              title: sound['name']!,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_outline),
                                    onPressed: () {
                                      _audioService.previewSound(sound['path']!,
                                          isAsset: true);
                                    },
                                  ),
                                  Radio<String>(
                                    value: sound['path']!,
                                    groupValue: settings.isCustomSound
                                        ? null
                                        : settings.selectedSound,
                                    onChanged: (value) {
                                      if (value != null) {
                                        settings.setSound(value, false);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                settings.setSound(sound['path']!, false);
                                _audioService.previewSound(sound['path']!,
                                    isAsset: true);
                              },
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      }),
                      // Custom sound option
                      _SettingsTile(
                        icon: Icons.folder_open_rounded,
                        title: l10n.customSound,
                        subtitle: settings.isCustomSound
                            ? settings.selectedSound.split('/').last
                            : l10n.chooseFile,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (settings.isCustomSound)
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () {
                                  _audioService.previewSound(
                                      settings.selectedSound,
                                      isAsset: false);
                                },
                              ),
                            Radio<bool>(
                              value: true,
                              groupValue: settings.isCustomSound ? true : null,
                              onChanged: (_) => _pickCustomSound(settings),
                            ),
                          ],
                        ),
                        onTap: () => _pickCustomSound(settings),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Volume Section
                _SectionHeader(title: 'Volume'),
                const SizedBox(height: 8),
                GlassmorphicCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_down_rounded),
                        Expanded(
                          child: Slider(
                            value: settings.volume,
                            onChanged: (value) => settings.setVolume(value),
                            onChangeEnd: (value) {
                              _audioService.setVolume(value);
                            },
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDark
                  ? AppColors.primaryAccentDark
                  : AppColors.primaryAccent,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
