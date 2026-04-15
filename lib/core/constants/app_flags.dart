/// Internal feature flags for MVP gating.
///
/// Flip flags here to enable internal-only features during development.
/// These will be replaced by proper role-based access when auth is added.
abstract final class AppFlags {
  /// Set to `true` to expose the Moderation Console in the Profile screen.
  /// Keep `false` for normal / external builds.
  static const bool enableModerationConsole = true;
}
