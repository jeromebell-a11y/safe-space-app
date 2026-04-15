import 'package:flutter/material.dart';

import '../../../core/models/report.dart';
import '../../../core/models/report_category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class NearbyActivityCard extends StatelessWidget {
  const NearbyActivityCard({super.key, required this.report});

  final Report report;

  Color get _severityAccent => switch (report.category) {
        ReportCategory.violence => AppColors.highSafety,
        ReportCategory.harassment ||
        ReportCategory.discrimination =>
          AppColors.elevatedSafety,
        _ => AppColors.lowSafety,
      };

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(report.createdAt);
    final recency = _formatRecency(age);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: _severityAccent,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        report.category.icon,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          report.category.label,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      Text(
                        recency,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (report.notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      report.notes,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRecency(Duration age) {
    if (age.inMinutes < 1) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    if (age.inHours < 24) return '${age.inHours}h ago';
    if (age.inDays == 1) return '1 day ago';
    return '${age.inDays} days ago';
  }
}
