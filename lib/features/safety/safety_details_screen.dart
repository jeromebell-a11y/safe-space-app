import 'package:flutter/material.dart';

import '../../core/models/safety_level.dart';
import '../../core/models/safety_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class SafetyDetailsScreen extends StatelessWidget {
  const SafetyDetailsScreen({super.key, required this.state});

  final SafetyState state;

  Color get _statusColor => switch (state.level) {
        SafetyLevel.low => AppColors.lowSafety,
        SafetyLevel.elevated => AppColors.elevatedSafety,
        SafetyLevel.high => AppColors.highSafety,
      };

  static const _mockIncidents = [
    _Incident(
      icon: Icons.warning_amber_rounded,
      title: 'Harassment report',
      timeAgo: '2 hours ago',
      confidence: 'Medium confidence',
    ),
    _Incident(
      icon: Icons.visibility_outlined,
      title: 'Suspicious activity',
      timeAgo: '5 hours ago',
      confidence: 'High confidence',
    ),
    _Incident(
      icon: Icons.volume_up_outlined,
      title: 'Disturbance reported',
      timeAgo: '11 hours ago',
      confidence: 'Medium confidence',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: AppSpacing.xl),
          Text('Recent Activity', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          ..._mockIncidents.map(_buildIncidentTile),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(state.label, style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(state.summary, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          ...state.bullets.map((bullet) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(bullet, style: AppTextStyles.body)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIncidentTile(_Incident incident) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              incident.icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incident.title, style: AppTextStyles.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${incident.timeAgo} · ${incident.confidence}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _Incident {
  const _Incident({
    required this.icon,
    required this.title,
    required this.timeAgo,
    required this.confidence,
  });

  final IconData icon;
  final String title;
  final String timeAgo;
  final String confidence;
}
