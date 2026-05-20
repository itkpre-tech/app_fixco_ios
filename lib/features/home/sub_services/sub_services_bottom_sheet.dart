import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import 'sub_service_categories_bottom_sheet.dart';

// -----------------------------------------------------------------------------
// IMAGE CACHE
// -----------------------------------------------------------------------------
final Map<String, ImageProvider> _imageProviderCache = {};

ImageProvider _resolveImageProvider(String imageData) {
  if (_imageProviderCache.containsKey(imageData)) {
    return _imageProviderCache[imageData]!;
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
  _imageProviderCache[imageData] = provider;
  return provider;
}

class CachedImage extends StatelessWidget {
  final String? imageData;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallback;

  const CachedImage({
    super.key,
    required this.imageData,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (imageData == null || imageData!.isEmpty) return fallback;
    final provider = _resolveImageProvider(imageData!);
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

// -----------------------------------------------------------------------------
// WAVE PAINTERS – now with const constructors
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// GLASS CARD
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// MAIN BOTTOM SHEET
// -----------------------------------------------------------------------------
class SubServicesBottomSheet extends StatefulWidget {
  final int serviceId;
  final String serviceName;

  const SubServicesBottomSheet({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<SubServicesBottomSheet> createState() => _SubServicesBottomSheetState();
}

class _SubServicesBottomSheetState extends State<SubServicesBottomSheet> {
  List<Map<String, dynamic>> _subServices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubServices();
  }

  Future<void> _fetchSubServices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Api.getSubServices(serviceId: widget.serviceId);
      if (mounted) {
        setState(() {
          _subServices = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load sub‑services. Please try again.';
          _loading = false;
        });
      }
    }
  }

  void _onSubServiceTap(Map<String, dynamic> subService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubServiceCategoriesBottomSheet(
        subServiceId: subService['id'],
        subServiceName: subService['name'] ?? 'Service',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gradient background – same as GradientScaffold
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

    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.5, 0.75, 1.0],
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
                child: const CustomPaint(painter: _TopWavePainter()), // now const works
              ),
              // Bottom wave overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.22,
                child: const CustomPaint(painter: _BottomWavePainter()), // now const works
              ),
              // Content column
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
                  // Simplified header – only title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.serviceName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Content area
                  Expanded(
                    child: _buildContent(scrollController),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchSubServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_subServices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.miscellaneous_services, size: 48, color: Colors.white38),
            SizedBox(height: 12),
            Text(
              'No sub‑services available\nfor this service.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _subServices.length,
        itemBuilder: (context, index) {
          final sub = _subServices[index];
          return _SubServiceCard(
            name: sub['name'] ?? 'Service',
            image: sub['image'] ?? '',
            onTap: () => _onSubServiceTap(sub),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SUB‑SERVICE CARD (glass style, same as home.dart)
// -----------------------------------------------------------------------------
class _SubServiceCard extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onTap;

  const _SubServiceCard({
    required this.name,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imageData: image,
                fit: BoxFit.cover,
                fallback: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.70)],
                    stops: const [0.40, 1.0],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}