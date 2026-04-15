import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/safety_zone.dart';

class SafetyZonesRepository {
  SafetyZonesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _zonesRef =>
      _firestore.collection('safety_zones');

  Future<SafetyZone?> fetchSafetyZone(String geohashPrefix) async {
    final doc = await _zonesRef.doc(geohashPrefix).get();
    if (!doc.exists) return null;
    return SafetyZone.fromMap(doc.data()!);
  }

  Future<void> upsertSafetyZone(SafetyZone zone) async {
    await _zonesRef.doc(zone.geohashPrefix).set(
          zone.toMap(),
          SetOptions(merge: true),
        );
  }
}
