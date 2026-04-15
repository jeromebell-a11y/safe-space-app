import 'safety_level.dart';

/// Lightweight UI payload derived from SafetyZone + recent Incidents.
///
/// Not necessarily stored in Firestore — composed on the client or by a
/// Cloud Function and served as a read-optimized document or computed
/// on the fly from SafetyZone data.
class SafetySnapshot {
  const SafetySnapshot({
    required this.level,
    required this.label,
    required this.summary,
    required this.bullets,
    required this.generatedAt,
  });

  final SafetyLevel level;
  final String label;
  final String summary;
  final List<String> bullets;
  final DateTime generatedAt;

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'label': label,
      'summary': summary,
      'bullets': bullets,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory SafetySnapshot.fromMap(Map<String, dynamic> map) {
    return SafetySnapshot(
      level: SafetyLevel.values.byName(map['level'] as String),
      label: map['label'] as String,
      summary: map['summary'] as String,
      bullets: List<String>.from(map['bullets'] as List),
      generatedAt: DateTime.parse(map['generatedAt'] as String),
    );
  }
}
