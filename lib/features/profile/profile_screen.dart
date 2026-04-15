import 'package:flutter/material.dart';

import '../../core/constants/app_flags.dart';
import '../../core/models/user_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../moderation/moderation_screen.dart';
import 'widgets/settings_section.dart';
import 'widgets/toggle_setting_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _prefs = const UserPreferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const Text('Safety Preferences', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Tune how Safe Space prioritizes alerts and safety awareness for you.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsSection(
              title: 'Safety Focus',
              subtitle: 'Choose what matters most to you',
              child: Column(
                children: [
                  ToggleSettingTile(
                    label: 'Prioritize harassment alerts',
                    subtitle: 'Highlight harassment-related reports',
                    value: _prefs.prioritizeHarassment,
                    onChanged: (v) => setState(() {
                      _prefs = _prefs.copyWith(prioritizeHarassment: v);
                    }),
                  ),
                  ToggleSettingTile(
                    label: 'Prioritize nighttime safety',
                    subtitle: 'Increase awareness after dark',
                    value: _prefs.prioritizeNightSafety,
                    onChanged: (v) => setState(() {
                      _prefs = _prefs.copyWith(prioritizeNightSafety: v);
                    }),
                  ),
                  ToggleSettingTile(
                    label: 'Prioritize crowded areas',
                    subtitle: 'Flag high-density locations',
                    value: _prefs.prioritizeCrowdedAreas,
                    onChanged: (v) => setState(() {
                      _prefs = _prefs.copyWith(prioritizeCrowdedAreas: v);
                    }),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsSection(
              title: 'Alerts',
              child: Column(
                children: [
                  ToggleSettingTile(
                    label: 'Enable notifications',
                    subtitle: 'Receive safety updates nearby',
                    value: _prefs.enableNotifications,
                    onChanged: (v) => setState(() {
                      _prefs = _prefs.copyWith(enableNotifications: v);
                    }),
                  ),
                  ToggleSettingTile(
                    label: 'Critical alerts only',
                    subtitle: 'Only notify for high-severity events',
                    value: _prefs.enableCriticalAlerts,
                    onChanged: (v) => setState(() {
                      _prefs = _prefs.copyWith(enableCriticalAlerts: v);
                    }),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Safe Space uses incident patterns to provide safety awareness.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Preferences shown here are local mock settings for the current MVP.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (AppFlags.enableModerationConsole) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ModerationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: const Text('Moderation Console'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
