// lib/features/home/widgets/home_carousels.dart

import 'package:flutter/material.dart';
import 'package:fixco/features/home/widgets/home_projects_details.dart';
import '../models/home_models.dart';
import 'home_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PromoCarousel
// ─────────────────────────────────────────────────────────────────────────────

class PromoCarousel extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onPageChanged;

  const PromoCarousel({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.onPrev,
    required this.onNext,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 164,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => onPageChanged(p % kPromos.length),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PromoCard(promo: kPromos[i % kPromos.length]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _CarouselControls(
          count: kPromos.length,
          current: currentPage,
          onPrev: onPrev,
          onNext: onNext,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OffersCarousel
// ─────────────────────────────────────────────────────────────────────────────

class OffersCarousel extends StatelessWidget {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;
  final PageController controller;
  final int currentPage;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageChanged;

  const OffersCarousel({
    super.key,
    required this.offers,
    required this.isLoading,
    required this.error,
    required this.controller,
    required this.currentPage,
    required this.onPrev,
    required this.onNext,
    required this.onRetry,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 190,
        child: Center(
          child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
        ),
      );
    }

    if (error != null) {
      return ErrorState(
        icon: Icons.local_offer_outlined,
        message: 'Failed to load offers',
        onRetry: onRetry,
      );
    }

    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => onPageChanged(p % offers.length),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: OfferCard(offer: offers[i % offers.length]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _CarouselControls(
          count: offers.length,
          current: currentPage,
          onPrev: onPrev,
          onNext: onNext,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProjectsCarousel
// ─────────────────────────────────────────────────────────────────────────────

class ProjectsCarousel extends StatelessWidget {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final PageController controller;
  final int currentPage;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageChanged;

  const ProjectsCarousel({
    super.key,
    required this.projects,
    required this.isLoading,
    required this.error,
    required this.controller,
    required this.currentPage,
    required this.onPrev,
    required this.onNext,
    required this.onRetry,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
        ),
      );
    }

    if (error != null) {
      return ErrorState(
        icon: Icons.image_not_supported_rounded,
        message: 'Failed to load projects',
        onRetry: onRetry,
      );
    }

    if (projects.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_off_rounded,
        title: 'No Projects Yet',
        subtitle: 'Completed projects will appear here.',
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => onPageChanged(p % projects.length),
            itemBuilder: (_, i) {
              final project = projects[i % projects.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ProjectCard(
                  project: project,
                  onView: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProjectDetailPage(projectId: project.id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _CarouselControls(
          count: projects.length,
          current: currentPage,
          onPrev: onPrev,
          onNext: onNext,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CarouselControls  (shared prev/dots/next row)
// ─────────────────────────────────────────────────────────────────────────────

class _CarouselControls extends StatelessWidget {
  final int count;
  final int current;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CarouselControls({
    required this.count,
    required this.current,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CarouselArrow(icon: Icons.chevron_left_rounded, onTap: onPrev),
          SmoothDots(count: count, current: current),
          CarouselArrow(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PromoCard
// ─────────────────────────────────────────────────────────────────────────────

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
                _PromoLabel(promo: promo),
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
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
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
              border: Border.all(
                color: promo.accent.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Icon(promo.icon, color: promo.accent, size: 34),
          ),
        ],
      ),
    );
  }
}

class _PromoLabel extends StatelessWidget {
  final PromoData promo;

  const _PromoLabel({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: promo.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: promo.accent.withValues(alpha: 0.35),
          width: 0.8,
        ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OfferCard
// ─────────────────────────────────────────────────────────────────────────────

class OfferCard extends StatelessWidget {
  final Offer offer;

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
    final hasImage = offer.image.isNotEmpty;
    final gradientColors = _gradients[offer.id.hashCode.abs() % _gradients.length];
    final shortDesc = offer.description.length > 60
        ? '${offer.description.substring(0, 57)}...'
        : offer.description;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: image or gradient
            if (hasImage)
              CachedImage(
                src: offer.image,
                fit: BoxFit.cover,
                fallback: _GradientBackground(colors: gradientColors),
              )
            else
              _GradientBackground(colors: gradientColors),
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
            // Left accent stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
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
            // OFFER badge
            Positioned(
              top: 14,
              left: 14,
              child: _OfferBadge(),
            ),
            // Date badge
            if (offer.endDateFormatted != null &&
                offer.endDateFormatted!.isNotEmpty)
              Positioned(
                top: 14,
                right: 14,
                child: _DateBadge(date: offer.endDateFormatted!),
              ),
            // Content
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (offer.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        shortDesc,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (offer.daysLeft != null && offer.daysLeft! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: kPrimaryLight.withValues(alpha: 0.8),
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.daysLeft} days left',
                            style: TextStyle(
                              color: kPrimaryLight.withValues(alpha: 0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

class _GradientBackground extends StatelessWidget {
  final List<Color> colors;

  const _GradientBackground({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _OfferBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today,
              color: kPrimaryLight.withValues(alpha: 0.8), size: 9),
          const SizedBox(width: 4),
          Text(
            date,
            style: TextStyle(
              color: kPrimaryLight.withValues(alpha: 0.9),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProjectCard
// ─────────────────────────────────────────────────────────────────────────────

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onView;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(
              src: project.coverImage,
              fallback: Container(
                color: kSurfaceHigh,
                child: const Icon(Icons.image_rounded,
                    color: kTextLight, size: 50),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.82),
                  ],
                  stops: const [0.28, 1.0],
                ),
              ),
            ),
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
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
            // Title + View button
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 14, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ViewButton(onTap: onView),
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

class _ViewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, kAccent]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'View',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProjectsSeeAll button
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
          border: Border.all(
            color: kPrimary.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See All',
              style: TextStyle(
                color: kPrimary.withValues(alpha: 0.90),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: kPrimary, size: 11),
            ),
          ],
        ),
      ),
    );
  }
}