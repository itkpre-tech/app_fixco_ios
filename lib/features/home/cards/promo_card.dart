import 'package:flutter/material.dart';
import '../models/promo_data.dart';

class PromoCard extends StatelessWidget {
  final PromoData promo;

  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: promo.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: promo.gradient.last.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: promo.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: promo.accent.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Text(
                    promo.label,
                    style: TextStyle(
                      color: promo.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  promo.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  promo.subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: promo.accent.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(color: promo.accent.withValues(alpha: 0.28), width: 1),
            ),
            child: Icon(promo.icon, color: promo.accent, size: 34),
          ),
        ],
      ),
    );
  }
}