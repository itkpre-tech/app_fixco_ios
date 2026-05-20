import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// -----------------------------------------------------------------------------
// IMAGE CACHE (same as other sheets)
// -----------------------------------------------------------------------------
final Map<String, ImageProvider> _bookingImageCache = {};

ImageProvider _resolveBookingImage(String imageData) {
  if (_bookingImageCache.containsKey(imageData)) {
    return _bookingImageCache[imageData]!;
  }
  ImageProvider provider;
  if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
    provider = NetworkImage(imageData);
  } else if (imageData.startsWith('data:image')) {
    try {
      final bytes = base64Decode(imageData.split(',').last);
      provider = MemoryImage(bytes);
    } catch (_) {
      provider = const NetworkImage('');
    }
  } else {
    provider = NetworkImage('http://admin.medco-contracting.com$imageData');
  }
  _bookingImageCache[imageData] = provider;
  return provider;
}

class _CachedBookingImage extends StatelessWidget {
  final String? imageData;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallback;

  const _CachedBookingImage({
    required this.imageData,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (imageData == null || imageData!.isEmpty) return fallback;
    final provider = _resolveBookingImage(imageData!);
    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

// ============================================================================
// WAVE PAINTERS (same as GradientScaffold)
// ============================================================================
class _TopWavePainter extends CustomPainter {
  const _TopWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.45)
      ..cubicTo(
        size.width * 0.70, size.height * 0.85,
        size.width * 0.30, size.height * 0.15,
        0, size.height * 0.65,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3D0808).withOpacity(0.45)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.55)
      ..cubicTo(
        size.width * 0.65, size.height * 0.15,
        size.width * 0.35, size.height * 0.85,
        0, size.height * 0.35,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5A0C0C).withOpacity(0.40)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ============================================================================
// GLASS CARD (identical to other sheets)
// ============================================================================
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 18.0,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.blur = 16.0,
    this.margin = EdgeInsets.zero,
    this.hasBorder = true,
  });

  final Widget child;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double blur;
  final EdgeInsetsGeometry margin;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              highlightColor: Colors.white.withOpacity(0.08),
              splashColor: Colors.white.withOpacity(0.12),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: hasBorder
                      ? Border.all(color: Colors.white.withOpacity(0.15), width: 0.8)
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SERVICE CATEGORY DETAILS BOTTOM SHEET – glass style, draggable 100% initial,
// snaps to 25%, 50%, 75%, 100%
// ============================================================================
class ServiceCategoryBookingSheet extends StatelessWidget {
  final Map<String, dynamic> category;

  const ServiceCategoryBookingSheet({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.50, 1.0],
      colors: [
        Color(0xFF1C0404),
        Color(0xFF6B1010),
        Color(0xFF1C0404),
      ],
    );

    final name = category['name']?.toString() ?? 'Service';
    final image = category['image']?.toString() ?? '';
    final description = category['description']?.toString() ?? '';
    final double price = double.tryParse(category['price']?.toString() ?? '0') ?? 0.0;
    final double rating = double.tryParse(category['rating']?.toString() ?? '0') ?? 0.0;
    final expectedTime = category['expected_time']?.toString() ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 1.0,       // start at 100%
      minChildSize: 0.25,          // can go down to 25%
      maxChildSize: 1.0,           // max 100%
      snap: true,
      snapSizes: const [0.25, 0.5, 0.75, 1.0],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              // Top wave overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.22,
                child: const CustomPaint(painter: _TopWavePainter()),
              ),
              // Bottom wave overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.22,
                child: const CustomPaint(painter: _BottomWavePainter()),
              ),
              Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Header with title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Service Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          // Hero image
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: _CachedBookingImage(
                                  imageData: image,
                                  fit: BoxFit.cover,
                                  fallback: const Icon(
                                    Icons.category_outlined,
                                    size: 80,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Details glass card
                          GlassCard(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (description.isNotEmpty)
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white24),
                                const SizedBox(height: 12),
                                // Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Price',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      '${price.toStringAsFixed(2)} AED',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Expected time
                                if (expectedTime.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Expected Time',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 18, color: Colors.white60),
                                          const SizedBox(width: 4),
                                          Text(
                                            expectedTime,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                // Rating
                                if (rating > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Rating',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            rating.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}