import 'report_category.dart';

class ReportDraft {
  const ReportDraft({
    this.category,
    this.notes = '',
    this.hasMockMedia = false,
  });

  final ReportCategory? category;
  final String notes;
  final bool hasMockMedia;

  ReportDraft copyWith({
    ReportCategory? category,
    String? notes,
    bool? hasMockMedia,
  }) {
    return ReportDraft(
      category: category ?? this.category,
      notes: notes ?? this.notes,
      hasMockMedia: hasMockMedia ?? this.hasMockMedia,
    );
  }
}
