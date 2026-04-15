import 'package:flutter/material.dart';

import '../../core/models/incident.dart';
import '../../core/models/report.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/nearby_activity_card.dart';
import 'widgets/nearby_incident_card.dart';

class NearbyActivityScreen extends StatelessWidget {
  const NearbyActivityScreen({
    super.key,
    this.reports = const [],
    this.incidents = const [],
  });

  final List<Report> reports;
  final List<Incident> incidents;

  bool get _isEmpty => incidents.isEmpty && reports.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Activity')),
      body: _isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.lowSafety,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No nearby activity',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'There are no recent incidents or reports in your area.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        if (incidents.isNotEmpty) ...[
          Text(
            '${incidents.length} verified incident${incidents.length == 1 ? '' : 's'}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final incident in incidents)
            NearbyIncidentCard(incident: incident),
        ],
        if (reports.isNotEmpty) ...[
          if (incidents.isNotEmpty) const SizedBox(height: AppSpacing.lg),
          Text(
            '${reports.length} unverified report${reports.length == 1 ? '' : 's'}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final report in reports) NearbyActivityCard(report: report),
        ],
      ],
    );
  }
}
