import '../models/report.dart';
import '../models/report_category.dart';
import '../models/safety_level.dart';
import '../models/safety_state.dart';

class SafetyScoringService {
  static const _categoryWeights = <ReportCategory, double>{
    ReportCategory.violence: 3.0,
    ReportCategory.harassment: 2.5,
    ReportCategory.suspiciousActivity: 2.0,
    ReportCategory.theft: 2.0,
    ReportCategory.discrimination: 2.0,
    ReportCategory.other: 1.0,
  };

  static const _elevatedThreshold = 3.0;
  static const _highThreshold = 8.0;

  SafetyState deriveFromReports(List<Report> reports) {
    if (reports.isEmpty) {
      return const SafetyState(
        level: SafetyLevel.low,
        label: 'Low Activity',
        summary: 'No recent reports in your area.',
        bullets: ['All clear — no incidents reported nearby'],
      );
    }

    final now = DateTime.now();
    double totalScore = 0;

    for (final report in reports) {
      final age = now.difference(report.createdAt);
      final recencyWeight = _recencyWeight(age);
      final categoryWeight =
          _categoryWeights[report.category] ?? 1.0;
      totalScore += recencyWeight * categoryWeight;
    }

    final level = _levelFromScore(totalScore);
    final label = _labelForLevel(level);
    final summary = _summaryForLevel(level);
    final bullets = _buildBullets(reports, now, totalScore);

    return SafetyState(
      level: level,
      label: label,
      summary: summary,
      bullets: bullets,
    );
  }

  double _recencyWeight(Duration age) {
    if (age.inHours < 6) return 1.0;
    if (age.inHours < 24) return 0.5;
    return 0.2;
  }

  SafetyLevel _levelFromScore(double score) {
    if (score >= _highThreshold) return SafetyLevel.high;
    if (score >= _elevatedThreshold) return SafetyLevel.elevated;
    return SafetyLevel.low;
  }

  String _labelForLevel(SafetyLevel level) => switch (level) {
        SafetyLevel.low => 'Low Activity',
        SafetyLevel.elevated => 'Elevated Activity',
        SafetyLevel.high => 'High Activity',
      };

  String _summaryForLevel(SafetyLevel level) => switch (level) {
        SafetyLevel.low =>
          'Minimal recent activity in your area.',
        SafetyLevel.elevated =>
          'Recent incident activity suggests increased awareness in this area.',
        SafetyLevel.high =>
          'Multiple significant reports suggest caution in this area.',
      };

  List<String> _buildBullets(
    List<Report> reports,
    DateTime now,
    double score,
  ) {
    final last24h =
        reports.where((r) => now.difference(r.createdAt).inHours < 24).length;

    final newest = reports.first;
    final age = now.difference(newest.createdAt);
    final recency = age.inMinutes < 60
        ? '${age.inMinutes}m ago'
        : '${age.inHours}h ago';

    final topCategory = _dominantCategory(reports);

    return [
      '${reports.length} report${reports.length == 1 ? '' : 's'} nearby '
          '(risk score: ${score.toStringAsFixed(1)})',
      '$last24h in the last 24 hours',
      'Most recent: ${newest.category.label}, $recency',
      if (topCategory != null) 'Top concern: ${topCategory.label}',
    ];
  }

  ReportCategory? _dominantCategory(List<Report> reports) {
    if (reports.isEmpty) return null;

    final counts = <ReportCategory, int>{};
    for (final r in reports) {
      counts[r.category] = (counts[r.category] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final countCmp = b.value.compareTo(a.value);
        if (countCmp != 0) return countCmp;
        return (_categoryWeights[b.key] ?? 1.0)
            .compareTo(_categoryWeights[a.key] ?? 1.0);
      });

    return sorted.first.key;
  }
}
