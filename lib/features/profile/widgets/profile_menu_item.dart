import 'package:flutter/material.dart';
import '../shared/profile_constants.dart';

/// A single tappable row used in the Profile menu list.
///
/// Encapsulates the card decoration, icon, label, and trailing arrow so that
/// adding or removing menu entries in [ProfilePage] requires only one line.
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = Colors.black54,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ProfileConstants.menuItemSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(ProfileConstants.menuItemBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileConstants.menuItemBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ProfileConstants.menuItemVerticalPadding,
            horizontal: ProfileConstants.menuItemHorizontalPadding,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: ProfileConstants.menuItemFontSize,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}