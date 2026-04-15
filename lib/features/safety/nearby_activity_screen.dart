import 'package:flutter/material.dart';

import '../../core/models/report.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/nearby_activity_card.dart';

class NearbyActivityScreen extends StatelessWidget {
  const NearbyActivityScreen({super.key, required this.reports});

  final List<Report> reports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Activity')),
      body: reports.isEmpty ? _buildEmpty() : _buildList(),
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
              'There are no recent reports in your area.',
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
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: reports.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              '${reports.length} report${reports.length == 1 ? '' : 's'} nearby',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        return NearbyActivityCard(report: reports[index - 1]);
      },
    );
  }
}
