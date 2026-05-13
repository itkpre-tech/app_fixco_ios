import 'package:flutter/material.dart';
import 'package:fixco/features/home/shared/home_constants.dart'; // kPrimary, kTextDark, kTextLight
import '../shared/profile_constants.dart';

/// Top title bar displayed on the Profile tab.
///
/// Matches the HomeTitleBar design language: app-badge pill + large heading +
/// subtitle. Kept stateless so it can be reused or tested in isolation.
class ProfileTitleBar extends StatelessWidget {
  const ProfileTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBadge(),
            const SizedBox(height: 13),
            _PageTitle(),
            const SizedBox(height: 5),
            _PageSubtitle(),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _AppBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary,
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            ProfileConstants.appBadgeLabel,
            style: TextStyle(
              color: kPrimary,
              fontSize: ProfileConstants.badgeFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      ProfileConstants.pageTitleLabel,
      style: TextStyle(
        fontSize: ProfileConstants.titleFontSize,
        fontWeight: FontWeight.w800,
        color: kTextDark,
        height: 1.1,
        letterSpacing: -0.4,
      ),
    );
  }
}

class _PageSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      ProfileConstants.pageSubtitleLabel,
      style: TextStyle(
        color: kTextLight,
        fontSize: ProfileConstants.subtitleFontSize,
      ),
    );
  }
}