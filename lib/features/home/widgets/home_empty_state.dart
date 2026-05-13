import 'package:flutter/material.dart';
import '../shared/home_constants.dart';

class HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const HomeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary.withValues(alpha: 0.06),
              border: Border.all(color: kPrimary.withValues(alpha: 0.18), width: 1.5),
            ),
            child: Icon(icon, color: kPrimary.withValues(alpha: 0.50), size: 34),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: kTextMid, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: kTextLight, fontSize: 13), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}