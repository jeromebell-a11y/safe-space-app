import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/models/geo_location.dart';
import '../../core/models/report.dart';
import '../../core/models/report_category.dart';
import '../../core/models/report_status.dart';
import '../../core/services/reports_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/report_category_chip.dart';
import 'widgets/report_media_placeholder.dart';
import 'widgets/report_notes_field.dart';
import 'widgets/report_success_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _repository = ReportsRepository();
  ReportCategory? _selectedCategory;
  final _notesController = TextEditingController();
  bool _hasMockMedia = false;
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _notesController.clear();
      _hasMockMedia = false;
      _isSubmitted = false;
      _isSubmitting = false;
    });
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final docId = FirebaseFirestore.instance.collection('reports').doc().id;
    final report = Report(
      id: docId,
      category: _selectedCategory!,
      notes: _notesController.text.trim(),
      hasMedia: _hasMockMedia,
      location: const GeoLocation(latitude: 0, longitude: 0),
      geohash: 'unknown',
      createdAt: DateTime.now(),
      status: ReportStatus.pending,
    );

    try {
      await _repository.submitReport(report);
      if (!mounted) return;
      setState(() {
        _isSubmitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit report. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Activity')),
      body: SafeArea(
        child: _isSubmitted
            ? ReportSuccessCard(onSubmitAnother: _reset)
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What happened?', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Select a category and add any details to help describe the situation.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Category',
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ReportCategory.values.map((category) {
              return ReportCategoryChip(
                category: category,
                isSelected: _selectedCategory == category,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Notes',
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          ReportNotesField(controller: _notesController),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Media',
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          ReportMediaPlaceholder(
            hasMedia: _hasMockMedia,
            onTap: () {
              setState(() {
                _hasMockMedia = !_hasMockMedia;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedCategory != null && !_isSubmitting
                  ? _submit
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Text('Submit Report'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
