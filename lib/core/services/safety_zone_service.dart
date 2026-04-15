import '../models/report.dart';
import '../models/report_category.dart';
import '../models/safety_zone.dart';

class SafetyZoneService {
  static const _categoryWeights = <ReportCategory, double>{
    ReportCategory.violence: 3.0,
    ReportCategory.harassment: 2.5,
    ReportCategory.suspiciousActivity: 2.0,
    ReportCategory.theft: 2.0,
    ReportCategory.discrimination: 2.0,
    ReportCategory.other: 1.0,
  };

  SafetyZone deriveFromReports(List<Report> reports, String geohashPrefix) {
    if (reports.isEmpty) {
      return SafetyZone(
        geohashPrefix: geohashPrefix,
        riskScore: 0,
        incidentCount: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final now = DateTime.now();
    double riskScore = 0;

    for (final report in reports) {
      final age = now.difference(report.createdAt);
      final recencyWeight = _recencyWeight(age);
      final categoryWeight = _categoryWeights[report.category] ?? 1.0;
      riskScore += recencyWeight * categoryWeight;
    }

    final mostRecent = reports
        .map((r) => r.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return SafetyZone(
      geohashPrefix: geohashPrefix,
      riskScore: double.parse(riskScore.toStringAsFixed(2)),
      incidentCount: reports.length,
      lastUpdated: mostRecent,
    );
  }

  double _recencyWeight(Duration age) {
    if (age.inHours < 6) return 1.0;
    if (age.inHours < 24) return 0.5;
    return 0.2;
  }
}
