import 'package:flutter/material.dart';

import '../../core/constants/app_flags.dart';
import '../../core/models/report.dart';
import '../../core/services/moderation_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/moderation_report_card.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  final _repository = ModerationRepository();

  List<Report> _pendingReports = const [];
  bool _isLoading = true;
  final Set<String> _actingIds = {};

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _repository.fetchPendingReports();
      if (!mounted) return;
      setState(() {
        _pendingReports = reports;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(Report report) async {
    setState(() => _actingIds.add(report.id));
    try {
      await _repository.approveReport(report);
      if (!mounted) return;
      setState(() {
        _pendingReports =
            _pendingReports.where((r) => r.id != report.id).toList();
        _actingIds.remove(report.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report approved — incident created')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _actingIds.remove(report.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approve failed: $e')),
      );
    }
  }

  Future<void> _reject(Report report) async {
    setState(() => _actingIds.add(report.id));
    try {
      await _repository.rejectReport(report);
      if (!mounted) return;
      setState(() {
        _pendingReports =
            _pendingReports.where((r) => r.id != report.id).toList();
        _actingIds.remove(report.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report rejected')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _actingIds.remove(report.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reject failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPending,
          ),
        ],
      ),
      body: !AppFlags.enableModerationConsole
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Not available',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Moderation access is restricted.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppColors.lowSafety.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No pending reports',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'All reports have been reviewed.',
                        style: AppTextStyles.caption.copyWith(
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPending,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _pendingReports.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(
                            '${_pendingReports.length} pending',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }

                      final report = _pendingReports[index - 1];
                      return ModerationReportCard(
                        report: report,
                        isActing: _actingIds.contains(report.id),
                        onApprove: () => _approve(report),
                        onReject: () => _reject(report),
                      );
                    },
                  ),
                ),
    );
  }
}
