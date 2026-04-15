import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report.dart';

class ReportsRepository {
  ReportsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  Future<void> submitReport(Report report) async {
    await _reportsRef.doc(report.id).set(report.toMap());
  }
}
