import 'package:flutter/material.dart';

import '../../../core/models/safety_zone.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ZoneSummaryChip extends StatelessWidget {
  const ZoneSummaryChip({super.key, required this.zone});

  final SafetyZone zone;

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(zone.lastUpdated);
    final updatedText = _formatUpdated(age);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadge(
            icon: Icons.shield_outlined,
            text: 'Risk ${zone.riskScore.toStringAsFixed(1)}',
          ),
          const SizedBox(width: AppSpacing.md),
          _buildBadge(
            icon: Icons.location_on_outlined,
            text:
                '${zone.incidentCount} nearby report${zone.incidentCount == 1 ? '' : 's'}',
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            updatedText,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatUpdated(Duration age) {
    if (age.inMinutes < 5) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    if (age.inHours < 24) return '${age.inHours}h ago';
    return '${age.inDays}d ago';
  }
}
