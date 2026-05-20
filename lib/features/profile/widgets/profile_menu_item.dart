import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_card.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.isDark = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;
    final chevronColor = isDark ? Colors.white38 : Colors.black38;

    return GlassCard(
      borderRadius: 18,
      margin: const EdgeInsets.only(bottom: 10),
      // Fixed padding: same vertical height as preference cards (14 top+bottom = 28 total)
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      blur: 14,
      isDark: isDark,
      onTap: onTap,
      child: Row(
        children: [
          _GlassIconBox(icon: icon, isDark: isDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showChevron && trailing == null)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: chevronColor,
            ),
        ],
      ),
    );
  }
}

class _GlassIconBox extends StatelessWidget {
  const _GlassIconBox({required this.icon, this.isDark = false});

  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}