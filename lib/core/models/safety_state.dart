import 'safety_level.dart';

class SafetyState {
  const SafetyState({
    required this.level,
    required this.label,
    required this.summary,
    required this.bullets,
  });

  final SafetyLevel level;
  final String label;
  final String summary;
  final List<String> bullets;
}
