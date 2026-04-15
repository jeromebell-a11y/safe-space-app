import 'package:flutter/material.dart';

enum ReportCategory {
  harassment,
  suspiciousActivity,
  theft,
  violence,
  discrimination,
  other;

  String get label => switch (this) {
        ReportCategory.harassment => 'Harassment',
        ReportCategory.suspiciousActivity => 'Suspicious Activity',
        ReportCategory.theft => 'Theft',
        ReportCategory.violence => 'Violence',
        ReportCategory.discrimination => 'Discrimination',
        ReportCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        ReportCategory.harassment => Icons.record_voice_over_outlined,
        ReportCategory.suspiciousActivity => Icons.visibility_outlined,
        ReportCategory.theft => Icons.lock_outlined,
        ReportCategory.violence => Icons.warning_amber_rounded,
        ReportCategory.discrimination => Icons.people_outlined,
        ReportCategory.other => Icons.more_horiz,
      };
}
