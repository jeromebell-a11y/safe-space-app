import 'geo_location.dart';
import 'incident_source_type.dart';

/// Firestore collection: `incidents`
///
/// Represents a validated or aggregated safety event.
/// Incidents are promoted from reports or ingested from official sources.
/// Indexed on: geohash, createdAt, type, severity.
class Incident {
  const Incident({
    required this.id,
    required this.type,
    required this.severity,
    required this.location,
    required this.geohash,
    required this.createdAt,
    required this.sourceType,
    this.confidenceScore = 0.0,
  });

  final String id;
  final String type;
  final int severity;
  final GeoLocation location;
  final String geohash;
  final DateTime createdAt;
  final IncidentSourceType sourceType;
  final double confidenceScore;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'location': location.toMap(),
      'geohash': geohash,
      'createdAt': createdAt.toIso8601String(),
      'sourceType': sourceType.name,
      'confidenceScore': confidenceScore,
    };
  }

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      id: map['id'] as String,
      type: map['type'] as String,
      severity: map['severity'] as int,
      location: GeoLocation.fromMap(map['location'] as Map<String, dynamic>),
      geohash: map['geohash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      sourceType: IncidentSourceType.values.byName(map['sourceType'] as String),
      confidenceScore: (map['confidenceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
