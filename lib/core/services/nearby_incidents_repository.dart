import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

class NearbyIncidentsRepository {
  NearbyIncidentsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _incidentsRef =>
      _firestore.collection('incidents');

  Future<List<Incident>> fetchRecent({
    int limit = 10,
    String? geohashPrefix,
  }) async {
    Query<Map<String, dynamic>> query = _incidentsRef
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (geohashPrefix != null && geohashPrefix.isNotEmpty) {
      final end = geohashPrefix.substring(0, geohashPrefix.length - 1) +
          String.fromCharCode(
            geohashPrefix.codeUnitAt(geohashPrefix.length - 1) + 1,
          );
      query = query
          .where('geohash', isGreaterThanOrEqualTo: geohashPrefix)
          .where('geohash', isLessThan: end);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Incident.fromMap(doc.data())).toList();
  }
}
