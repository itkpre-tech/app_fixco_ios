import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fixco/services/api.dart';
import '../../gradient_scaffold.dart';

// ============================================================================
// GLASS CARD — ultra-transparent, near-invisible border
// ============================================================================
class GlassCard extends StatefulWidget {
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
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _up(TapUpDetails _) {
    if (widget.onTap == null) return;
    _ctrl.reverse();
  }

  void _cancel() {
    if (widget.onTap == null) return;
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTapDown: _down,
          onTapUp: _up,
          onTapCancel: _cancel,
          onTap: widget.onTap,
          child: Container(
            margin: widget.margin,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: widget.blur, sigmaY: widget.blur),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius:
                    BorderRadius.circular(widget.borderRadius),
                    border: widget.hasBorder
                        ? Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 0.8,
                    )
                        : null,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ARROW BUTTON — transparent blurred circle, white icon
// ============================================================================
class ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.18), width: 0.8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DOTS INDICATOR
// ============================================================================
class DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: on
                ? Colors.white
                : Colors.white.withOpacity(0.30),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ============================================================================
// SVG ICON WIDGET — inline SVG paths, always white
// ============================================================================
class _SvgIcon extends StatelessWidget {
  final String svgPath;
  final double size;
  const _SvgIcon(this.svgPath, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SvgPainter(svgPath, size),
      ),
    );
  }
}

class _SvgPainter extends CustomPainter {
  final String id;
  final double size;
  const _SvgPainter(this.id, this.size);

  @override
  void paint(Canvas canvas, Size sz) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = sz.width / 24;

    switch (id) {
      case 'verified':
        final shield = Path()
          ..moveTo(12 * s, 2 * s)
          ..lineTo(20 * s, 6 * s)
          ..lineTo(20 * s, 12 * s)
          ..cubicTo(20 * s, 16.5 * s, 16.5 * s, 20.5 * s, 12 * s, 22 * s)
          ..cubicTo(7.5 * s, 20.5 * s, 4 * s, 16.5 * s, 4 * s, 12 * s)
          ..lineTo(4 * s, 6 * s)
          ..close();
        canvas.drawPath(shield, paint);
        final check = Path()
          ..moveTo(8.5 * s, 12 * s)
          ..lineTo(11 * s, 14.5 * s)
          ..lineTo(15.5 * s, 9.5 * s);
        canvas.drawPath(check, paint);
        break;

      case 'speed':
        final rect = Rect.fromCircle(
            center: Offset(12 * s, 13 * s), radius: 8 * s);
        canvas.drawArc(rect, 3.14 * 0.75, 3.14 * 1.5, false, paint);
        final needle = Path()
          ..moveTo(12 * s, 13 * s)
          ..lineTo(8 * s, 8 * s);
        canvas.drawPath(needle, paint);
        canvas.drawCircle(Offset(12 * s, 13 * s), 1.2 * s,
            paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        break;

      case 'pricing':
        final tag = Path()
          ..moveTo(12 * s, 2 * s)
          ..lineTo(20 * s, 10 * s)
          ..lineTo(13 * s, 17 * s)
          ..cubicTo(12.2 * s, 17.8 * s, 11 * s, 17.8 * s, 10.2 * s, 17 * s)
          ..lineTo(3 * s, 10 * s)
          ..lineTo(3 * s, 4 * s)
          ..lineTo(9 * s, 4 * s)
          ..close();
        canvas.drawPath(tag, paint);
        canvas.drawCircle(Offset(7.5 * s, 7.5 * s), 1.0 * s,
            paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        break;

      case 'warranty':
        final outer = Path()
          ..moveTo(12 * s, 2 * s)
          ..lineTo(15 * s, 5 * s)
          ..lineTo(19 * s, 5 * s)
          ..lineTo(19 * s, 9 * s)
          ..lineTo(22 * s, 12 * s)
          ..lineTo(19 * s, 15 * s)
          ..lineTo(19 * s, 19 * s)
          ..lineTo(15 * s, 19 * s)
          ..lineTo(12 * s, 22 * s)
          ..lineTo(9 * s, 19 * s)
          ..lineTo(5 * s, 19 * s)
          ..lineTo(5 * s, 15 * s)
          ..lineTo(2 * s, 12 * s)
          ..lineTo(5 * s, 9 * s)
          ..lineTo(5 * s, 5 * s)
          ..lineTo(9 * s, 5 * s)
          ..close();
        canvas.drawPath(outer, paint);
        final wCheck = Path()
          ..moveTo(8.5 * s, 12 * s)
          ..lineTo(11 * s, 14.5 * s)
          ..lineTo(15.5 * s, 9.5 * s);
        canvas.drawPath(wCheck, paint);
        break;

      case 'availability':
        canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, paint);
        final hands = Path()
          ..moveTo(12 * s, 7 * s)
          ..lineTo(12 * s, 12 * s)
          ..lineTo(16 * s, 14.5 * s);
        canvas.drawPath(hands, paint);
        break;

      case 'location':
        final pin = Path()
          ..moveTo(12 * s, 22 * s)
          ..cubicTo(12 * s, 22 * s, 5 * s, 15 * s, 5 * s, 10 * s)
          ..cubicTo(5 * s, 6.1 * s, 8.1 * s, 3 * s, 12 * s, 3 * s)
          ..cubicTo(15.9 * s, 3 * s, 19 * s, 6.1 * s, 19 * s, 10 * s)
          ..cubicTo(19 * s, 15 * s, 12 * s, 22 * s, 12 * s, 22 * s)
          ..close();
        canvas.drawPath(pin, paint);
        canvas.drawCircle(Offset(12 * s, 10 * s), 2.5 * s, paint);
        break;

      case 'business':
        final bldg = Path()
          ..moveTo(4 * s, 22 * s)
          ..lineTo(4 * s, 4 * s)
          ..lineTo(16 * s, 4 * s)
          ..lineTo(16 * s, 22 * s);
        canvas.drawPath(bldg, paint);
        canvas.drawLine(Offset(2 * s, 22 * s), Offset(22 * s, 22 * s), paint);
        canvas.drawLine(Offset(16 * s, 10 * s), Offset(20 * s, 10 * s), paint);
        canvas.drawLine(Offset(20 * s, 10 * s), Offset(20 * s, 22 * s), paint);
        for (final x in [7.0, 12.0]) {
          for (final y in [8.0, 13.0, 18.0]) {
            canvas.drawRect(
                Rect.fromCenter(
                    center: Offset(x * s, y * s),
                    width: 2 * s,
                    height: 2 * s),
                paint);
          }
        }
        break;

      case 'person':
        canvas.drawCircle(Offset(12 * s, 8 * s), 4 * s, paint);
        final body = Path()
          ..moveTo(4 * s, 22 * s)
          ..cubicTo(4 * s, 18 * s, 7.6 * s, 15 * s, 12 * s, 15 * s)
          ..cubicTo(16.4 * s, 15 * s, 20 * s, 18 * s, 20 * s, 22 * s);
        canvas.drawPath(body, paint);
        break;

      case 'openlink':
        final box = Path()
          ..moveTo(10 * s, 5 * s)
          ..lineTo(5 * s, 5 * s)
          ..lineTo(5 * s, 19 * s)
          ..lineTo(19 * s, 19 * s)
          ..lineTo(19 * s, 14 * s);
        canvas.drawPath(box, paint);
        final arrow = Path()
          ..moveTo(14 * s, 4 * s)
          ..lineTo(20 * s, 4 * s)
          ..lineTo(20 * s, 10 * s);
        canvas.drawPath(arrow, paint);
        canvas.drawLine(
            Offset(20 * s, 4 * s), Offset(11 * s, 13 * s), paint);
        break;

      case 'star':
        final star = Path();
        const pts = 5;
        const outerR = 9.0;
        const innerR = 4.0;
        for (int i = 0; i < pts * 2; i++) {
          final r = i.isEven ? outerR : innerR;
          final angle = (i * 3.14159 / pts) - 3.14159 / 2;
          final x = 12 + r * cos(angle);
          final y = 12 + r * sin(angle);
          if (i == 0)
            star.moveTo(x * s, y * s);
          else
            star.lineTo(x * s, y * s);
        }
        star.close();
        canvas.drawPath(
            star,
            Paint()
              ..color = Colors.amber.withOpacity(0.90)
              ..style = PaintingStyle.fill);
        break;

      case 'chevron_down':
        final ch = Path()
          ..moveTo(6 * s, 9 * s)
          ..lineTo(12 * s, 15 * s)
          ..lineTo(18 * s, 9 * s);
        canvas.drawPath(ch, paint);
        break;

      case 'add':
        canvas.drawLine(
            Offset(12 * s, 5 * s), Offset(12 * s, 19 * s), paint);
        canvas.drawLine(
            Offset(5 * s, 12 * s), Offset(19 * s, 12 * s), paint);
        break;

      case 'certificate':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(3 * s, 4 * s, 18 * s, 14 * s),
                Radius.circular(2 * s)),
            paint);
        canvas.drawLine(
            Offset(7 * s, 9 * s), Offset(17 * s, 9 * s), paint);
        canvas.drawLine(
            Offset(7 * s, 12 * s), Offset(14 * s, 12 * s), paint);
        canvas.drawCircle(Offset(12 * s, 21 * s), 2.5 * s, paint);
        canvas.drawLine(
            Offset(9.5 * s, 21 * s), Offset(9.5 * s, 18 * s), paint);
        canvas.drawLine(
            Offset(14.5 * s, 21 * s), Offset(14.5 * s, 18 * s), paint);
        break;
    }
  }

  double cos(double a) => dart_math_cos(a);
  double sin(double a) => dart_math_sin(a);

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
}

double dart_math_cos(double a) => _cos(a);
double dart_math_sin(double a) => _sin(a);

double _sin(double x) {
  x = x % (2 * 3.14159265358979);
  double result = x;
  double term = x;
  for (int n = 1; n <= 7; n++) {
    term *= -x * x / ((2 * n) * (2 * n + 1));
    result += term;
  }
  return result;
}

double _cos(double x) {
  x = x % (2 * 3.14159265358979);
  double result = 1;
  double term = 1;
  for (int n = 1; n <= 7; n++) {
    term *= -x * x / ((2 * n - 1) * (2 * n));
    result += term;
  }
  return result;
}

// ============================================================================
// EXPANDABLE SECTION ITEM
// ============================================================================
class ExpandableSectionItem extends StatefulWidget {
  final String title;
  final String description;
  final String svgIconId;
  const ExpandableSectionItem({
    super.key,
    required this.title,
    required this.description,
    required this.svgIconId,
  });

  @override
  State<ExpandableSectionItem> createState() => _ExpandableSectionItemState();
}

class _ExpandableSectionItemState extends State<ExpandableSectionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _SvgIcon(widget.svgIconId, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: _SvgIcon(_isExpanded ? 'add' : 'add', size: 18),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 12),
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.65),
                height: 1.45,
              ),
            ),
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.white.withOpacity(0.12),
          indent: 36,
          endIndent: 0,
        ),
      ],
    );
  }
}

// ============================================================================
// IMAGE CACHE
// ============================================================================
final Map<String, ImageProvider> _imageCache = {};

ImageProvider _resolveImage(String src) {
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

class CachedImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Widget fallback;
  const CachedImage(
      {super.key, required this.src, this.fit = BoxFit.cover, required this.fallback});

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) return fallback;
    return Image(
        image: _resolveImage(src!),
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => fallback);
  }
}

// ============================================================================
// REVIEW MODEL
// ============================================================================
class Review {
  final String name, job, review, profileImagePath;
  final double rating;
  Review(
      {required this.name,
        required this.job,
        required this.review,
        required this.profileImagePath,
        required this.rating});
}

final List<Review> _reviews = [
  Review(
      name: "Noor Al Kafre",
      job: "Information & Technology Manager",
      review:
      "Exceptional service from start to finish! The team was professional, punctual, and delivered outstanding maintenance work with great attention to detail.",
      profileImagePath: "assets/images/noor.jpeg",
      rating: 5.0),
  Review(
      name: "Mohamed Al Hamdhy",
      job: "Software Engineer",
      review:
      "One of the most reliable maintenance companies in Dubai. Their response time, workmanship, and customer support have always exceeded our expectations.",
      profileImagePath: "assets/images/Person4.png",
      rating: 5.0),
  Review(
      name: "Catherine",
      job: "Villa Owner",
      review:
      "I am extremely satisfied with their painting service. The finish was clean, modern, and completed on time with excellent professionalism throughout.",
      profileImagePath: "assets/images/Person6.jpg",
      rating: 4.9),
];

final List<Map<String, dynamic>> _whyChooseUsItems = [
  {'title': 'Verified Experts', 'description': 'All our professionals are thoroughly vetted, licensed, and experienced to ensure top-quality service delivery.', 'svg': 'verified'},
  {'title': 'Fast Response', 'description': 'Get quick responses and same-day service availability for urgent repairs and installations.', 'svg': 'speed'},
  {'title': 'Affordable Pricing', 'description': 'Transparent pricing with no hidden charges. Get the best value for your money.', 'svg': 'pricing'},
  {'title': 'Warranty Support', 'description': 'All our services come with warranty coverage for your peace of mind.', 'svg': 'warranty'},
  {'title': 'Availability', 'description': 'We are available 7 days a week to serve you at your convenience.', 'svg': 'availability'},
];

// ============================================================================
// MAIN ABOUT PAGE
// ============================================================================
class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  List<dynamic> _certificates = [];
  bool _isLoadingCertificates = true;
  late final PageController _reviewCtrl =
  PageController(viewportFraction: 0.92, initialPage: 1000);
  int _reviewPage = 0;
  Timer? _reviewTimer;

  @override
  void initState() {
    super.initState();
    _fetchCertificates(isInitialLoad: true);
    _startReviewTimer();
    _reviewCtrl.addListener(() {
      if (_reviewCtrl.page != null) {
        final p = _reviewCtrl.page!.round();
        if (p != _reviewPage)
          setState(() => _reviewPage = p % _reviews.length);
      }
    });
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    _reviewTimer?.cancel();
    super.dispose();
  }

  void _startReviewTimer() {
    _reviewTimer?.cancel();
    _reviewTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_reviewCtrl.hasClients) return;
      _reviewCtrl.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut);
    });
  }

  /// Pull-to-refresh handler — mirrors contact.dart's `_refresh()`:
  /// short delay, then silently fetch new data with no loading indicator.
  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) await _fetchCertificates(isInitialLoad: false);
    if (mounted) setState(() {});
  }

  /// [isInitialLoad] = true  → show spinner until first data arrives.
  /// [isInitialLoad] = false → silent background fetch; existing data stays
  ///                           visible the whole time (no spinner, no flicker).
  Future<void> _fetchCertificates({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      setState(() => _isLoadingCertificates = true);
    }
    final certs = await Api.getCertificates();
    if (mounted) {
      setState(() {
        _certificates = certs;
        // Only clear the loading flag on initial load; during refresh it was
        // never set to true so this is a no-op either way.
        if (isInitialLoad) _isLoadingCertificates = false;
      });
    }
  }

  // ── shared text styles ────────────────────────────────────────────────────
  TextStyle get _sectionTitle => const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.3);

  static const _bodyStyle =
  TextStyle(color: Colors.white, fontSize: 13, height: 1.45);

  static final _mutedStyle =
  TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 12);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 30;

    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.10),
        child: CustomScrollView(
          // AlwaysScrollableScrollPhysics keeps the page pinned (no bounce /
          // overscroll shift) and enables pull-to-refresh — identical to
          // contact.dart and home.dart.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Title Bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildTitleBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            // ── 1. About ──────────────────────────────────────────────────
            SliverToBoxAdapter(child: _pad(_buildAboutCard())),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 2. Leadership ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel("Leadership")),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _pad(_buildLeadershipCard())),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 3. Branches ───────────────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel("Our Branches")),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _pad(_BranchCard(
                svgId: 'location',
                branches: const [
                  _BranchItem(
                      name: "Dubai",
                      subtitle: "Head Office",
                      url: "https://kingspalace.com/",
                      isHeadOffice: true),
                ],
              )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 4. Sister Companies ───────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel("Sister Companies")),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: _pad(_BranchCard(
                svgId: 'business',
                branches: const [
                  _BranchItem(
                      name: "Kings' Palace Real Estate",
                      url: "https://kingspalace.com/"),
                  _BranchItem(
                      name: "Kings' Land Consultancy",
                      url: "https://kingspalace.com/"),
                ],
              )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 5. Certifications ─────────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel("Certifications")),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
                child: _pad(_buildCertificatesGrid())),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 6. Why Choose Us ──────────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel("Why Choose Us")),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _pad(_buildWhyChooseUs())),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 7. Reviews ────────────────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel("What Our Clients Say")),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
                child: _pad(_buildReviewCarousel())),

            SliverPadding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(text, style: _sectionTitle),
  );

  Widget _buildTitleBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: const Text(
          'About Us',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/fixco.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.white.withOpacity(0.08),
                    child: _SvgIcon('business', size: 36),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "MEDCO Contracting delivers reliable, high-quality maintenance services across the UAE with expert teams and fast response.",
                  style: _bodyStyle.copyWith(
                      color: Colors.white.withOpacity(0.75)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatItem(value: "30+", label: "Years")),
              Expanded(child: _StatItem(value: "22", label: "Nationalities")),
              Expanded(child: _StatItem(value: "25", label: "Languages")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadershipCard() {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/images/chairman.png",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.white.withOpacity(0.08),
                child: _SvgIcon('person', size: 36),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "H.E. Dr. Sami Al Sawalehi",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text("Founder & Visionary Leader",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.60),
                        fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  "Leading MEDCO's growth across the UAE and international markets since 1991.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.60),
                      fontSize: 12,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: _whyChooseUsItems
            .map((item) => ExpandableSectionItem(
          title: item['title'] as String,
          description: item['description'] as String,
          svgIconId: item['svg'] as String,
        ))
            .toList(),
      ),
    );
  }

  Widget _buildCertificatesGrid() {
    if (_isLoadingCertificates) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: Colors.white)));
    }

    if (_certificates.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text("No certifications available",
              style: TextStyle(color: Colors.white.withOpacity(0.60))),
        ),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < _certificates.length; i += 2) {
      final c1 = _certificates[i];
      final c2 = i + 1 < _certificates.length ? _certificates[i + 1] : null;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: AspectRatio(
                  aspectRatio: 0.82,
                  child: _CertCard(
                      imageUrl: c1['image'] ?? '',
                      title: c1['title'] ?? 'Certificate',
                      description: c1['description'] ?? ''))),
          const SizedBox(width: 10),
          Expanded(
              child: c2 != null
                  ? AspectRatio(
                  aspectRatio: 0.82,
                  child: _CertCard(
                      imageUrl: c2['image'] ?? '',
                      title: c2['title'] ?? 'Certificate',
                      description: c2['description'] ?? ''))
                  : const SizedBox.shrink()),
        ],
      ));
      if (i + 2 < _certificates.length) rows.add(const SizedBox(height: 10));
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows);
  }

  Widget _buildReviewCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _reviewCtrl,
            onPageChanged: (p) =>
                setState(() => _reviewPage = p % _reviews.length),
            itemBuilder: (_, i) {
              final review = _reviews[i % _reviews.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _ReviewCard(review: review),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _reviewCtrl.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut),
              ),
              DotsIndicator(count: _reviews.length, current: _reviewPage),
              ArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _reviewCtrl.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STAT ITEM
// ============================================================================
class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(label,
            style:
            TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 12)),
      ],
    );
  }
}

// ============================================================================
// BRANCH CARD
// ============================================================================
class _BranchItem {
  final String name, url;
  final String? subtitle;
  final bool isHeadOffice;
  const _BranchItem(
      {required this.name,
        required this.url,
        this.subtitle,
        this.isHeadOffice = false});
}

class _BranchCard extends StatelessWidget {
  final String svgId;
  final List<_BranchItem> branches;
  const _BranchCard({required this.svgId, required this.branches});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(branches.length, (index) {
          final b = branches[index];
          final isLast = index == branches.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _launch(b.url),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _SvgIcon(svgId, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(b.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ),
                                if (b.isHeadOffice) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius:
                                      BorderRadius.circular(999),
                                      border: Border.all(
                                          color:
                                          Colors.amber.withOpacity(0.45),
                                          width: 0.8),
                                    ),
                                    child: const Text('HQ',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.amber,
                                            letterSpacing: 0.8)),
                                  ),
                                ],
                              ],
                            ),
                            if (b.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(b.subtitle!,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 11)),
                            ],
                          ],
                        ),
                      ),
                      _SvgIcon('openlink', size: 16),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.white.withOpacity(0.12),
                  indent: 52,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ============================================================================
// CERTIFICATE CARD
// ============================================================================
class _CertCard extends StatelessWidget {
  final String imageUrl, title, description;
  const _CertCard(
      {required this.imageUrl,
        required this.title,
        required this.description});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 14,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImage(
            src: imageUrl.isNotEmpty ? imageUrl : null,
            fit: BoxFit.cover,
            fallback: Container(
              color: Colors.white.withOpacity(0.06),
              child: Center(
                  child: _SvgIcon('certificate', size: 40)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding:
                  const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.3)),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 9,
                                height: 1.2)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REVIEW CARD
// ============================================================================
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  review.profileImagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text(
                            review.name.isNotEmpty ? review.name[0] : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(review.job,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.review,
            style: TextStyle(
                color: Colors.white.withOpacity(0.70),
                fontSize: 11,
                height: 1.35),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final v = index + 1;
              if (v <= review.rating.floor())
                return const Icon(Icons.star_rounded,
                    color: Colors.amber, size: 14);
              if (v - review.rating > 0 && v - review.rating < 1)
                return const Icon(Icons.star_half_rounded,
                    color: Colors.amber, size: 14);
              return Icon(Icons.star_border_rounded,
                  color: Colors.white.withOpacity(0.30), size: 14);
            }),
          ),
        ],
      ),
    );
  }
}