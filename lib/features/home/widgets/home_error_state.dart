import 'package:flutter/material.dart';
import '../shared/home_constants.dart';

class HomeErrorState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const HomeErrorState({
    super.key,
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.06),
              border: Border.all(color: Colors.red.withValues(alpha: 0.18), width: 1.5),
            ),
            child: Icon(icon, color: Colors.redAccent.withValues(alpha: 0.65), size: 30),
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: kTextLight, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: kPrimary.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 5)),
                ],
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}