import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_source_type.dart';
import '../models/report.dart';
import '../models/report_category.dart';
import '../models/report_status.dart';

class ModerationRepository {
  ModerationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _incidentsRef =>
      _firestore.collection('incidents');

  Future<List<Report>> fetchPendingReports() async {
    final snapshot = await _reportsRef
        .where('status', isEqualTo: ReportStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Report.fromMap(doc.data()))
        .toList();
  }

  Future<void> approveReport(Report report) async {
    final batch = _firestore.batch();

    batch.update(_reportsRef.doc(report.id), {
      'status': ReportStatus.approved.name,
    });

    final incident = Incident(
      id: report.id,
      type: report.category.name,
      severity: _severityFromCategory(report.category),
      location: report.location,
      geohash: report.geohash,
      createdAt: report.createdAt,
      sourceType: IncidentSourceType.user,
      confidenceScore: report.confidenceScore ?? 0.5,
    );

    batch.set(_incidentsRef.doc(incident.id), incident.toMap());

    await batch.commit();
  }

  Future<void> rejectReport(Report report) async {
    await _reportsRef.doc(report.id).update({
      'status': ReportStatus.rejected.name,
    });
  }

  int _severityFromCategory(ReportCategory category) => switch (category) {
        ReportCategory.violence => 5,
        ReportCategory.harassment => 4,
        ReportCategory.discrimination => 3,
        ReportCategory.suspiciousActivity => 3,
        ReportCategory.theft => 3,
        ReportCategory.other => 2,
      };
}
