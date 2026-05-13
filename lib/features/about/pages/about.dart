import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fixco/services/api.dart';
import '../../home/shared/home_constants.dart'; // provides kPrimary, kAccent, kTextDark, kTextLight

// Local light-theme tokens
const Color _bgLight = Color(0xFFFFFFFF);
const Color _textMid = Color(0xFF555555);
const Color _borderColor = Color(0xFF000000);

// ─────────────────────────────────────────────
// Image cache helper
// ─────────────────────────────────────────────
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

class _CachedImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Widget fallback;
  const _CachedImage({
    required this.src,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) return fallback;
    return Image(
      image: _resolveImage(src!),
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

// ─────────────────────────────────────────────
// Review Model
// ─────────────────────────────────────────────
class Review {
  final String name, job, review, profileImagePath;
  final double rating;

  Review({
    required this.name,
    required this.job,
    required this.review,
    required this.profileImagePath,
    required this.rating,
  });
}

final List<Review> _reviews = [
  Review(
    name: "Noor Al Kafri",
    job: "Homeowner",
    review: "Exceptional service! Professional team, highly recommended!",
    profileImagePath: "assets/images/noor.jpeg",
    rating: 5.0,
  ),
  Review(
    name: "Mohamed Al Hamdi",
    job: "Property Manager",
    review: "Best maintenance company in Dubai! Very reliable.",
    profileImagePath: "assets/images/Person4.png",
    rating: 5.0,
  ),
  Review(
    name: "Sherif",
    job: "Business Owner",
    review: "Amazing electrical work! Very detail-oriented team.",
    profileImagePath: "assets/images/Person1.png",
    rating: 4.8,
  ),
  Review(
    name: "Maged",
    job: "Villa Owner",
    review: "Fast response, fair pricing, quality work every time.",
    profileImagePath: "assets/images/Person2.png",
    rating: 5.0,
  ),
  Review(
    name: "Catherine",
    job: "Homeowner",
    review: "Very satisfied with their painting service! Excellent!",
    profileImagePath: "assets/images/Person6.jpg",
    rating: 4.9,
  ),
];

// ─────────────────────────────────────────────
// About Page
// ─────────────────────────────────────────────
class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  List<dynamic> _certificates = [];
  bool _isLoadingCertificates = true;

  late final PageController _reviewCtrl = PageController(
    viewportFraction: 0.88,
    initialPage: 1000,
  );

  int _reviewPage = 0;
  Timer? _reviewTimer;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
    _startReviewTimer();

    _reviewCtrl.addListener(() {
      if (_reviewCtrl.page != null) {
        final newPage = _reviewCtrl.page!.round();
        if (newPage != _reviewPage) {
          setState(() => _reviewPage = newPage % _reviews.length);
        }
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
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _refresh() async {
    await _fetchCertificates();
    if (mounted) setState(() {});
  }

  Future<void> _fetchCertificates() async {
    setState(() => _isLoadingCertificates = true);
    final certificates = await Api.getCertificates();
    setState(() {
      _certificates = certificates;
      _isLoadingCertificates = false;
    });
  }

  /// Glassmorphism card wrapper
  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  TextStyle get _sectionTitle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: kTextDark,
    letterSpacing: -0.2,
  );

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 30;

    return Scaffold(
      backgroundColor: _bgLight,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: kPrimary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Title Bar ──
            const SliverToBoxAdapter(child: AboutTitleBar()),

            // ── Section 1: About card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _glass(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/images/fixco.png",
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.black12,
                            child: const Icon(Icons.business,
                                size: 40, color: Colors.black38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "MEDCO Contracting delivers reliable, high-quality maintenance services across the UAE with expert teams and fast response.",
                          style: TextStyle(color: _textMid),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Stat Numbers ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Expanded(child: StatCard("30+", "Years")),
                    SizedBox(width: 10),
                    Expanded(child: StatCard("22", "Nationalities")),
                    SizedBox(width: 10),
                    Expanded(child: StatCard("25", "Languages")),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // ── Section 2: Our Branches ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Our Branches", style: _sectionTitle),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BranchCard(
                  icon: Icons.location_city_outlined,
                  branches: const [
                    BranchItem(
                      name: "Dubai",
                      subtitle: "Head Office",
                      url: "https://kingspalace.com/",
                      isHeadOffice: true,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // ── Section 3: Sister Companies ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Sister Companies", style: _sectionTitle),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BranchCard(
                  icon: Icons.business_outlined,
                  branches: const [
                    BranchItem(
                      name: "Kings' Palace Real Estate",
                      url: "https://kingspalace.com/",
                    ),
                    BranchItem(
                      name: "Kings' Land Consultancy",
                      url: "https://kingspalace.com/",
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // ── Section 4: Certifications ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Certifications", style: _sectionTitle),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCertificatesGrid(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // ── Section 5: What Our Clients Say ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("What Our Clients Say", style: _sectionTitle),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildReviewCarousel(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // ── Section 6: Leadership ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Leadership", style: _sectionTitle),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _glass(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/images/chairman.png",
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.black12,
                            child: const Icon(Icons.person,
                                size: 40, color: Colors.black38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "H.E. Dr. Sami Al Sawalehi",
                              style: TextStyle(
                                color: kTextDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Founder & Visionary Leader",
                              style: TextStyle(color: kTextLight, fontSize: 12),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Leading MEDCO's growth across the UAE and international markets since 1991.",
                              style: TextStyle(
                                color: _textMid,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom safe-area padding — nothing hidden under nav bar ──
            SliverPadding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Certificates Grid (manual rows — no GridView spacing issues)
  // ─────────────────────────────────────────────
  Widget _buildCertificatesGrid() {
    if (_isLoadingCertificates) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: CircularProgressIndicator(color: kPrimary),
        ),
      );
    }

    if (_certificates.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borderColor.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Text(
                "No certifications available",
                style: TextStyle(color: kTextLight),
              ),
            ),
          ),
        ),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < _certificates.length; i += 2) {
      final cert1 = _certificates[i];
      final cert2 = i + 1 < _certificates.length ? _certificates[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.82,
                child: CertCard(
                  imageUrl: cert1['image'] ?? '',
                  title: cert1['title'] ?? 'Certificate',
                  description: cert1['description'] ?? '',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: cert2 != null
                  ? AspectRatio(
                aspectRatio: 0.82,
                child: CertCard(
                  imageUrl: cert2['image'] ?? '',
                  title: cert2['title'] ?? 'Certificate',
                  description: cert2['description'] ?? '',
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );

      if (i + 2 < _certificates.length) {
        rows.add(const SizedBox(height: 10));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  // ─────────────────────────────────────────────
  // Review Carousel
  // ─────────────────────────────────────────────
  Widget _buildReviewCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _reviewCtrl,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final reviewIndex = index % _reviews.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _ReviewCard(review: _reviews[reviewIndex]),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CarouselArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => _reviewCtrl.previousPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                ),
              ),
              _SmoothDots(count: _reviews.length, current: _reviewPage),
              _CarouselArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => _reviewCtrl.nextPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Title Bar
// ─────────────────────────────────────────────
class AboutTitleBar extends StatelessWidget {
  const AboutTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kPrimary.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'MEDCO CONTRACTING',
                    style: TextStyle(
                      color: kPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'About Us',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: kTextDark,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Learn more about MEDCO Contracting',
              style: TextStyle(color: kTextLight, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Review Card
// ─────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  String get _truncatedReview {
    if (review.review.length <= 50) return review.review;
    return '${review.review.substring(0, 47)}...';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        review.profileImagePath,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [kPrimary, kAccent],
                            ),
                            border: Border.all(
                              color: _borderColor.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              review.name.isNotEmpty ? review.name[0] : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.name,
                            style: const TextStyle(
                              color: kTextDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            review.job,
                            style: const TextStyle(color: kTextLight, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _truncatedReview,
                  style: const TextStyle(
                    color: _textMid,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    if (starValue <= review.rating.floor()) {
                      return const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 18);
                    } else if (starValue - review.rating > 0 &&
                        starValue - review.rating < 1) {
                      return const Icon(Icons.star_half_rounded,
                          color: Colors.amber, size: 18);
                    } else {
                      return const Icon(Icons.star_border_rounded,
                          color: Colors.black26, size: 18);
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Smooth Dots
// ─────────────────────────────────────────────
class _SmoothDots extends StatelessWidget {
  final int count;
  final int current;
  const _SmoothDots({required this.count, required this.current});

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
          width: active ? 24.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: active
                ? const LinearGradient(colors: [kPrimary, kAccent])
                : null,
            color: active ? null : Colors.black.withValues(alpha: 0.15),
            boxShadow: active
                ? [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.35),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Carousel Arrow
// ─────────────────────────────────────────────
class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CarouselArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.6),
          border: Border.all(
            color: _borderColor.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
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

// ─────────────────────────────────────────────
// Cert Card
// ─────────────────────────────────────────────
class CertCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const CertCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CachedImage(
            src: imageUrl.isNotEmpty ? imageUrl : null,
            fit: BoxFit.cover,
            fallback: Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: const Center(
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.black26,
                  size: 40,
                ),
              ),
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
                        Colors.white.withValues(alpha: 0.92),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textMid,
                            fontSize: 9,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _borderColor.withValues(alpha: 0.12),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Branch Item / Card
// ─────────────────────────────────────────────
class BranchItem {
  final String name;
  final String? subtitle;
  final String url;
  final bool isHeadOffice;

  const BranchItem({
    required this.name,
    required this.url,
    this.subtitle,
    this.isHeadOffice = false,
  });
}

class BranchCard extends StatelessWidget {
  final IconData icon;
  final List<BranchItem> branches;

  const BranchCard({super.key, required this.icon, required this.branches});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, size: 18, color: _textMid),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        b.name,
                                        style: const TextStyle(
                                          color: kTextDark,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (b.isHeadOffice) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                          BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.amber
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Text(
                                          'HQ',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.amber,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (b.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    b.subtitle!,
                                    style: const TextStyle(
                                        color: kTextLight, fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.open_in_new_rounded,
                              size: 16, color: kTextLight),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black.withValues(alpha: 0.07),
                      indent: 66,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stat Card
// ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: _textMid, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}