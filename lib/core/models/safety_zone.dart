/// Firestore collection: `safety_zones`
///
/// Aggregated safety data per geographic area using geohash prefixes.
/// Short prefixes (~4-5 chars) cover larger areas; longer prefixes are
/// more precise. Updated periodically as new incidents are processed.
/// Indexed on: geohashPrefix, lastUpdated.
class SafetyZone {
  const SafetyZone({
    required this.geohashPrefix,
    required this.riskScore,
    required this.incidentCount,
    required this.lastUpdated,
  });

  final String geohashPrefix;
  final double riskScore;
  final int incidentCount;
  final DateTime lastUpdated;

  Map<String, dynamic> toMap() {
    return {
      'geohashPrefix': geohashPrefix,
      'riskScore': riskScore,
      'incidentCount': incidentCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory SafetyZone.fromMap(Map<String, dynamic> map) {
    return SafetyZone(
      geohashPrefix: map['geohashPrefix'] as String,
      riskScore: (map['riskScore'] as num).toDouble(),
      incidentCount: map['incidentCount'] as int,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}
