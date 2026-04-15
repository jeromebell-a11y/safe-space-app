import 'package:flutter/material.dart';

import '../../core/models/report_category.dart';
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
  ReportCategory? _selectedCategory;
  final _notesController = TextEditingController();
  bool _hasMockMedia = false;
  bool _isSubmitted = false;

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
    });
  }

  void _submit() {
    setState(() {
      _isSubmitted = true;
    });
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
              onPressed: _selectedCategory != null ? _submit : null,
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
              child: const Text('Submit Report'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
