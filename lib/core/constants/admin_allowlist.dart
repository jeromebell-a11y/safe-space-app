/// Internal admin allowlist for MVP access control.
///
/// Add authenticated user UIDs here to grant moderation access.
/// This will be replaced by Firebase custom claims or Firestore roles later.
abstract final class AdminAllowlist {
  static const Set<String> _allowedUids = {
    // Add admin UIDs here, e.g.:
    // 'abc123def456',
  };

  /// Returns `true` if the given UID is in the admin allowlist.
  static bool isAdmin(String? uid) {
    if (uid == null) return false;
    return _allowedUids.contains(uid);
  }
}
