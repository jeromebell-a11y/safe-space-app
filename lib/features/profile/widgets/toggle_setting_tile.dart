import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ToggleSettingTile extends StatelessWidget {
  const ToggleSettingTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    )),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.textPrimary,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
      ],
    );
  }
}
