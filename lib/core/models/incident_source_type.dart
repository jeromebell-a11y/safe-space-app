enum IncidentSourceType {
  user,
  official,
  system;

  String get label => switch (this) {
        IncidentSourceType.user => 'User',
        IncidentSourceType.official => 'Official',
        IncidentSourceType.system => 'System',
      };
}
