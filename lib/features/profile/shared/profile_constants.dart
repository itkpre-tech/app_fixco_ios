/// Shared constants used across the Profile feature.
///
/// Keeps magic strings, dimensions, and durations in one place so
/// every widget in the feature stays in sync automatically.
class ProfileConstants {
  ProfileConstants._();

  // ── Labels ────────────────────────────────────────────────────────────────
  static const String appBadgeLabel = 'MEDCO CONTRACTING';
  static const String pageTitleLabel = 'Profile';
  static const String pageSubtitleLabel = 'Manage your account and preferences';

  static const String menuProfile = 'Profile';
  static const String menuPrivacyPolicy = 'Privacy Policy';
  static const String menuTerms = 'Terms \& Conditions';
  static const String menuHelp = 'Help';

  static const String logoutButton = 'Logout';

  // ── Dimensions ────────────────────────────────────────────────────────────
  static const double horizontalPadding = 16.0;
  static const double menuItemBorderRadius = 14.0;
  static const double menuItemVerticalPadding = 14.0;
  static const double menuItemHorizontalPadding = 14.0;
  static const double menuItemSpacing = 12.0;

  static const double avatarRadius = 42.0;
  static const double cardBorderRadius = 18.0;

  static const double titleFontSize = 26.0;
  static const double subtitleFontSize = 14.0;
  static const double badgeFontSize = 10.0;
  static const double menuItemFontSize = 16.0;

  // ── Durations ─────────────────────────────────────────────────────────────
  static const Duration refreshDelay = Duration(milliseconds: 800);
}