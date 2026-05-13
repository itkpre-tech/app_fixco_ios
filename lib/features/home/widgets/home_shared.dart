// lib/features/home/widgets/home_shared.dart
//
// Brand tokens, image resolution, and reusable micro-widgets
// shared across all home sub-widgets.

import 'dart:convert';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand tokens
// ─────────────────────────────────────────────────────────────────────────────

const Color kPrimary      = Color(0xFFE65100);
const Color kPrimaryLight = Color(0xFFFF8A50);
const Color kAccent       = Color(0xFFFF6D2D);
const Color kBgWhite      = Color(0xFFFFFFFF);
const Color kSurface      = Color(0xFFF5F5F5);
const Color kSurfaceHigh  = Color(0xFFEEEEEE);
const Color kTextDark     = Color(0xFF1A1A1A);
const Color kTextMid      = Color(0xFF666666);
const Color kTextLight    = Color(0xFFAAAAAA);

// ─────────────────────────────────────────────────────────────────────────────
// Image cache
// ─────────────────────────────────────────────────────────────────────────────

final Map<String, ImageProvider> _imageCache = {};

ImageProvider resolveImage(String src) {
  if (_imageCache.containsKey(src)) return _imageCache[src]!;
  ImageProvider p;
  if (src.startsWith('http://') || src.startsWith('https://')) {
    p = NetworkImage(src);
  } else if (src.startsWith('data:image')) {
    try {
      p = MemoryImage(base64Decode(src.split(',').last));
    } catch (_) {
      p = const NetworkImage('');
    }
  } else {
    p = NetworkImage('http://admin.medco-contracting.com$src');
  }
  _imageCache[src] = p;
  return p;
}

void prewarmImage(String src) {
  if (src.isNotEmpty) resolveImage(src);
}

// ─────────────────────────────────────────────────────────────────────────────
// CachedImage
// ─────────────────────────────────────────────────────────────────────────────

class CachedImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Widget fallback;

  const CachedImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) return fallback;
    return Image(
      image: resolveImage(src!),
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SmoothDots
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
        final active = i == current % count.clamp(1, count);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: active
                ? const LinearGradient(colors: [kPrimary, kPrimaryLight])
                : null,
            color: active ? null : Colors.grey.withValues(alpha: 0.28),
            boxShadow: active
                ? [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CarouselArrow
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: kPrimary, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PillButton
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
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SectionHeader
// ─────────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? kPrimary, size: 20),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextDark,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EmptyState / ErrorState
// ─────────────────────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary.withValues(alpha: 0.06),
              border: Border.all(
                color: kPrimary.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: kPrimary.withValues(alpha: 0.50), size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: kTextMid,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: kTextLight, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.06),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
            child: Icon(icon,
                color: Colors.redAccent.withValues(alpha: 0.65), size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: kTextLight, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PromoData + static catalogue
// ─────────────────────────────────────────────────────────────────────────────

class PromoData {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const PromoData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}

const List<PromoData> kPromos = [
  PromoData(label: 'WELCOME OFFER', title: 'Exclusive Discount\nOn Your First\nBooking', subtitle: 'Book before the month ends', icon: Icons.local_offer_rounded, gradient: [Color(0xFF5C0000), Color(0xFFB71C1C)], accent: Color(0xFFFF8A80)),
  PromoData(label: 'NEW SERVICE', title: 'Professional\nPainting\nServices', subtitle: 'Transform your space with expert painters', icon: Icons.format_paint_rounded, gradient: [Color(0xFF143314), Color(0xFF2E7D32)], accent: Color(0xFF69F0AE)),
  PromoData(label: 'NEW SERVICE', title: 'Packers &\nMovers\nService', subtitle: 'Safe and hassle-free relocation', icon: Icons.local_shipping_rounded, gradient: [Color(0xFF0D0D1E), Color(0xFF1A237E)], accent: Color(0xFF82B1FF)),
  PromoData(label: 'NEW SERVICE', title: 'Expert\nHandyman\nServices', subtitle: 'Quick fixes for all your home needs', icon: Icons.handyman_rounded, gradient: [Color(0xFF3E1400), Color(0xFFBF360C)], accent: Color(0xFFFFAB91)),
  PromoData(label: 'NEW SERVICE', title: 'Reliable\nPlumbing\nSolutions', subtitle: 'Fast and efficient plumbing services', icon: Icons.plumbing_rounded, gradient: [Color(0xFF001A5C), Color(0xFF1565C0)], accent: Color(0xFF82B1FF)),
  PromoData(label: 'NEW SERVICE', title: 'Certified\nElectrical\nWorks', subtitle: 'Safe and professional electricians', icon: Icons.bolt_rounded, gradient: [Color(0xFF3E2400), Color(0xFFF57F17)], accent: Color(0xFFFFE57F)),
  PromoData(label: 'NEW SERVICE', title: 'AC Service &\nRepair', subtitle: 'Stay cool with expert AC maintenance', icon: Icons.ac_unit_rounded, gradient: [Color(0xFF001520), Color(0xFF01579B)], accent: Color(0xFF80D8FF)),
  PromoData(label: 'PREMIUM CARE', title: 'Annual\nMaintenance\nContracts', subtitle: 'Hassle-free home maintenance all year', icon: Icons.verified_rounded, gradient: [Color(0xFF141F14), Color(0xFF2E7D32)], accent: Color(0xFFC8E6C9)),
];