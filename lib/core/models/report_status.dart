enum ReportStatus {
  pending,
  approved,
  rejected;

  String get label => switch (this) {
        ReportStatus.pending => 'Pending',
        ReportStatus.approved => 'Approved',
        ReportStatus.rejected => 'Rejected',
      };
}
