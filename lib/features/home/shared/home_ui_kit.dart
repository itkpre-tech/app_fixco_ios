import 'package:flutter/material.dart';
import 'home_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Smooth Dots indicator
// ─────────────────────────────────────────────────────────────────────────────
class SmoothDots extends StatelessWidget {
  final int count;
  final int current;

  const SmoothDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width:  active ? 24.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: active
                ? const LinearGradient(colors: [kPrimary, kPrimaryLight])
                : null,
            color: active ? null : Colors.grey.withValues(alpha: 0.28),
            boxShadow: active
                ? [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carousel Arrow button
// ─────────────────────────────────────────────────────────────────────────────
class CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CarouselArrow({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kSurface,
          border: Border.all(color: kPrimary.withValues(alpha: 0.30), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, color: kPrimary, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill Button
// ─────────────────────────────────────────────────────────────────────────────
class PillButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  const PillButton({
    super.key,
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Projects "See All" button
// ─────────────────────────────────────────────────────────────────────────────
class ProjectsSeeAll extends StatelessWidget {
  final VoidCallback onTap;

  const ProjectsSeeAll({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: kPrimary.withValues(alpha: 0.08),
          border: Border.all(color: kPrimary.withValues(alpha: 0.35), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See All',
              style: TextStyle(color: kPrimary.withValues(alpha: 0.90), fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 5),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimary.withValues(alpha: 0.15)),
              child: const Icon(Icons.arrow_forward_rounded, color: kPrimary, size: 11),
            ),
          ],
        ),
      ),
    );
  }
}