import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ReportMediaPlaceholder extends StatelessWidget {
  const ReportMediaPlaceholder({
    super.key,
    required this.hasMedia,
    required this.onTap,
  });

  final bool hasMedia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: hasMedia ? AppColors.textPrimary.withValues(alpha: 0.04) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasMedia ? AppColors.textPrimary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasMedia ? Icons.check_circle_outline : Icons.camera_alt_outlined,
              size: 20,
              color: hasMedia ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              hasMedia ? '1 attachment added' : 'Add photo or media',
              style: AppTextStyles.body.copyWith(
                color: hasMedia ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: hasMedia ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
