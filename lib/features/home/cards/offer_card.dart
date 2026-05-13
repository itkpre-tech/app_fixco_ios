import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_image_helper.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;

  const OfferCard({super.key, required this.offer});

  static const _gradients = [
    [Color(0xFF5C0000), Color(0xFFB71C1C)],
    [Color(0xFF143314), Color(0xFF2E7D32)],
    [Color(0xFF0D0D1E), Color(0xFF1A237E)],
    [Color(0xFF3E1400), Color(0xFFBF360C)],
    [Color(0xFF001A5C), Color(0xFF1565C0)],
    [Color(0xFF3E2400), Color(0xFFF57F17)],
    [Color(0xFF001520), Color(0xFF01579B)],
  ];

  @override
  Widget build(BuildContext context) {
    final hasImage       = offer.image.isNotEmpty;
    final gradientColors = _gradients[offer.id.hashCode.abs() % _gradients.length];
    final shortDesc      = offer.description.length > 60
        ? '${offer.description.substring(0, 57)}...'
        : offer.description;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (hasImage)
              HomeCachedImage(
                src: offer.image,
                fit: BoxFit.cover,
                fallback: _GradientBox(colors: gradientColors),
              )
            else
              _GradientBox(colors: gradientColors),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: hasImage ? 0.15 : 0.0),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),

            // Left accent bar
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kPrimary, kAccent],
                  ),
                ),
              ),
            ),

            // OFFER badge (top left)
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer, size: 10, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'OFFER',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
            ),

            // End date badge (top right)
            if (offer.endDateFormatted != null && offer.endDateFormatted!.isNotEmpty)
              Positioned(
                top: 14, right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, color: kPrimaryLight.withValues(alpha: 0.8), size: 9),
                      const SizedBox(width: 4),
                      Text(
                        offer.endDateFormatted!,
                        style: TextStyle(color: kPrimaryLight.withValues(alpha: 0.9), fontSize: 8, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom content
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (offer.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        shortDesc,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (offer.daysLeft != null && offer.daysLeft! > 0) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.timer_outlined, color: kPrimaryLight.withValues(alpha: 0.8), size: 10),
                        const SizedBox(width: 4),
                        Text(
                          '${offer.daysLeft} days left',
                          style: TextStyle(color: kPrimaryLight.withValues(alpha: 0.9), fontSize: 9, fontWeight: FontWeight.w500),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBox extends StatelessWidget {
  final List<Color> colors;
  const _GradientBox({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
    );
  }
}