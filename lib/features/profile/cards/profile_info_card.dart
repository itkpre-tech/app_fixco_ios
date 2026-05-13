import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../shared/profile_constants.dart';

/// Displays the authenticated user's profile details inside a rounded card.
///
/// Accepts a fully resolved [ProfileModel] — all loading/error states are
/// handled upstream in [UserProfilePage] before this card is rendered.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileConstants.cardBorderRadius),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _AvatarCircle(initials: profile.initials),
            const SizedBox(height: 16),
            _InfoRow(title: 'Full Name', value: profile.fullName),
            const Divider(),
            _InfoRow(title: 'Email', value: profile.email),
            const Divider(),
            _InfoRow(title: 'Mobile', value: profile.phone),
            const Divider(),
            _InfoRow(title: 'Member Since', value: profile.memberSince),
            const Divider(),
            _InfoRow(
              title: 'Total Bookings',
              value: profile.bookingsCount.toString(),
            ),
            const Divider(),
            _InfoRow(
              title: 'Completed Jobs',
              value: profile.completedCount.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: ProfileConstants.avatarRadius,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}