import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pingme/l10n/app_localizations.dart';
import 'package:pingme/services/permission_service.dart';
import 'package:pingme/utils/constants.dart';
import 'package:pingme/widgets/glassmorphic_card.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;

  const PermissionScreen({super.key, required this.onPermissionGranted});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();
  bool _isChecking = false;
  bool _overlayGranted = false;
  bool _batteryOptDisabled = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final hasOverlay = await _permissionService.isOverlayPermissionGranted();
    final hasBatteryOpt = await Permission.ignoreBatteryOptimizations.isGranted;

    if (mounted) {
      setState(() {
        _overlayGranted = hasOverlay;
        _batteryOptDisabled = hasBatteryOpt;

        if (!hasOverlay) {
          _currentStep = 0;
        } else if (!hasBatteryOpt) {
          _currentStep = 1;
        } else {
          _currentStep = 2;
        }
      });

      // All permissions granted
      if (hasOverlay && hasBatteryOpt) {
        widget.onPermissionGranted();
      }
    }
  }

  Future<void> _requestOverlayPermission() async {
    setState(() => _isChecking = true);
    await _permissionService.requestOverlayPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _requestBatteryOptimization() async {
    setState(() => _isChecking = true);
    await Permission.ignoreBatteryOptimizations.request();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE0E7FF),
                    const Color(0xFFF8FAFC),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withAlpha(38),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryAccent.withAlpha(77),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    size: 50,
                    color: isDark
                        ? AppColors.primaryAccentDark
                        : AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Setup Required',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'सेटअप आवश्यक आहे',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Step 1: Overlay Permission
                _buildPermissionCard(
                  step: 1,
                  isActive: _currentStep == 0,
                  isCompleted: _overlayGranted,
                  icon: Icons.layers_rounded,
                  titleEn: 'Overlay Permission',
                  titleMr: 'ओव्हरले परवानगी',
                  descEn: 'Allow PingMe to show reminders over other apps',
                  descMr: 'इतर ॲप्सवर स्मरणपत्रे दाखवण्यासाठी परवानगी द्या',
                  buttonText: _overlayGranted ? 'Granted ✓' : 'Grant Permission',
                  onPressed: _overlayGranted ? null : _requestOverlayPermission,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Step 2: Battery Optimization
                _buildPermissionCard(
                  step: 2,
                  isActive: _currentStep == 1,
                  isCompleted: _batteryOptDisabled,
                  icon: Icons.battery_saver_rounded,
                  titleEn: 'Disable Battery Optimization',
                  titleMr: 'बॅटरी ऑप्टिमायझेशन बंद करा',
                  descEn: 'Required for reminders to work when app is closed',
                  descMr: 'ॲप बंद असताना स्मरणपत्रे काम करण्यासाठी आवश्यक',
                  buttonText: _batteryOptDisabled ? 'Disabled ✓' : 'Disable',
                  onPressed: _batteryOptDisabled ? null : _requestBatteryOptimization,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Step 3: Autostart (Manual - info only)
                _buildInfoCard(
                  step: 3,
                  icon: Icons.autorenew_rounded,
                  titleEn: 'Enable Autostart (If available)',
                  titleMr: 'ऑटोस्टार्ट सक्षम करा (उपलब्ध असल्यास)',
                  descEn: 'On Xiaomi, Oppo, Vivo, Realme phones:\n'
                      '• Go to Settings > Apps > PingMe\n'
                      '• Enable "Autostart" or "Auto-launch"\n'
                      '• Set battery saver to "No restrictions"',
                  descMr: 'Xiaomi, Oppo, Vivo, Realme फोनवर:\n'
                      '• Settings > Apps > PingMe वर जा\n'
                      '• "Autostart" किंवा "Auto-launch" सक्षम करा\n'
                      '• बॅटरी सेव्हर "No restrictions" वर सेट करा',
                  buttonText: 'Open App Settings',
                  onPressed: _openAppSettings,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // Continue button (only if overlay is granted)
                if (_overlayGranted)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onPermissionGranted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.doneButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _batteryOptDisabled
                                ? 'Continue / पुढे जा'
                                : 'Skip for now / आत्ता वगळा',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required int step,
    required bool isActive,
    required bool isCompleted,
    required IconData icon,
    required String titleEn,
    required String titleMr,
    required String descEn,
    required String descMr,
    required String buttonText,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    final color = isCompleted
        ? AppColors.doneButton
        : (isActive ? AppColors.primaryAccent : Colors.grey);

    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isCompleted
          ? AppColors.doneButton.withAlpha(26)
          : (isActive ? null : Colors.grey.withAlpha(13)),
      borderColor: isCompleted
          ? AppColors.doneButton.withAlpha(77)
          : (isActive ? AppColors.primaryAccent.withAlpha(77) : Colors.grey.withAlpha(38)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleEn,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      titleMr,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.doneButton : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AppColors.doneButton : color.withAlpha(128),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Center(
                        child: Text(
                          '$step',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descEn,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descMr,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark.withAlpha(179)
                  : AppColors.textSecondaryLight.withAlpha(179),
            ),
          ),
          if (!isCompleted && isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        buttonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required int step,
    required IconData icon,
    required String titleEn,
    required String titleMr,
    required String descEn,
    required String descMr,
    required String buttonText,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.orange.withAlpha(13),
      borderColor: Colors.orange.withAlpha(51),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleEn,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      titleMr,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.orange, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descEn,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descMr,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark.withAlpha(179)
                  : AppColors.textSecondaryLight.withAlpha(179),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.settings_rounded),
              label: Text(buttonText),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
