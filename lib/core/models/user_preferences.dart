class UserPreferences {
  const UserPreferences({
    this.prioritizeHarassment = true,
    this.prioritizeNightSafety = true,
    this.prioritizeCrowdedAreas = false,
    this.enableNotifications = true,
    this.enableCriticalAlerts = false,
  });

  final bool prioritizeHarassment;
  final bool prioritizeNightSafety;
  final bool prioritizeCrowdedAreas;
  final bool enableNotifications;
  final bool enableCriticalAlerts;

  UserPreferences copyWith({
    bool? prioritizeHarassment,
    bool? prioritizeNightSafety,
    bool? prioritizeCrowdedAreas,
    bool? enableNotifications,
    bool? enableCriticalAlerts,
  }) {
    return UserPreferences(
      prioritizeHarassment: prioritizeHarassment ?? this.prioritizeHarassment,
      prioritizeNightSafety: prioritizeNightSafety ?? this.prioritizeNightSafety,
      prioritizeCrowdedAreas: prioritizeCrowdedAreas ?? this.prioritizeCrowdedAreas,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableCriticalAlerts: enableCriticalAlerts ?? this.enableCriticalAlerts,
    );
  }
}
