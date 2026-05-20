import 'dart:ui';
import 'package:flutter/material.dart';

// ============================================================================
// SKELETON SYSTEM
// Usage examples:
//
//   SkeletonBox(width: 200, height: 20)          // single line / block
//   SkeletonCircle(size: 48)                     // avatar
//   SkeletonCard(child: ...)                     // glass-style card wrapper
//   SkeletonListTile()                           // icon + two lines (list row)
//   SkeletonParagraph(lines: 3)                  // block of text lines
//   SkeletonGrid(count: 4, crossAxisCount: 2,    // image grid
//               childAspectRatio: 0.82)
//   SkeletonCarousel(height: 185)                // horizontal card strip
//   SkeletonPage(sections: [...])                // full-page layout builder
//
// All shimmer from a single inherited ShimmerScope — just wrap your loading
// widget tree once with ShimmerScope and every child picks up the animation.
// ============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// 1. SHIMMER SCOPE  (inherited widget that drives the animation)
// ─────────────────────────────────────────────────────────────────────────────
class ShimmerScope extends StatefulWidget {
  final Widget child;

  /// Base shimmer colour (the "off" state).
  final Color baseColor;

  /// Highlight colour (the bright sweep).
  final Color highlightColor;

  const ShimmerScope({
    super.key,
    required this.child,
    this.baseColor = const Color(0x22FFFFFF),
    this.highlightColor = const Color(0x44FFFFFF),
  });

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();

  static _ShimmerScopeState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ShimmerScopeState>();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> get shimmer => _anim;
  Color get baseColor => widget.baseColor;
  Color get highlightColor => widget.highlightColor;

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SHIMMER PAINTER  (draws the animated gradient onto any box)
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerPainter extends CustomPainter {
  final double progress;   // -1.5 → 2.5
  final Color baseColor;
  final Color highlightColor;
  final double borderRadius;

  const _ShimmerPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // base fill
    canvas.drawRRect(
        rrect, Paint()..color = baseColor);

    // sweep gradient
    final sweepWidth = size.width * 0.55;
    final left = size.width * progress - sweepWidth / 2;

    final gradient = LinearGradient(
      colors: [
        baseColor,
        highlightColor,
        baseColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
          Rect.fromLTWH(left, 0, sweepWidth, size.height));

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. SKELETON BOX  — the atomic building block
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final scope = ShimmerScope.of(context);
    if (scope == null) {
      // Fallback if not inside a ShimmerScope
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: scope.shimmer,
      builder: (_, __) => SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ShimmerPainter(
            progress: scope.shimmer.value,
            baseColor: scope.baseColor,
            highlightColor: scope.highlightColor,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SKELETON CIRCLE  — avatars / icons
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) =>
      SkeletonBox(width: size, height: size, borderRadius: size / 2);
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. SKELETON CARD  — glass-style wrapper (matches GlassCard)
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. SKELETON LIST TILE  — icon + title + subtitle row
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonListTile extends StatelessWidget {
  /// Show a leading circle (avatar) instead of a square icon box.
  final bool leadingCircle;
  final double leadingSize;

  const SkeletonListTile({
    super.key,
    this.leadingCircle = false,
    this.leadingSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        leadingCircle
            ? SkeletonCircle(size: leadingSize)
            : SkeletonBox(
            width: leadingSize,
            height: leadingSize,
            borderRadius: 12),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBox(height: 14, borderRadius: 6),
              const SizedBox(height: 8),
              SkeletonBox(width: 140, height: 11, borderRadius: 6),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. SKELETON PARAGRAPH  — n lines of text
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonParagraph extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;

  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.lineHeight = 13,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (i) {
        final isLast = i == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          // Last line is shorter — looks natural
          child: SkeletonBox(
            width: isLast ? null : null, // full width except last
            height: lineHeight,
            borderRadius: 6,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. SKELETON GRID  — image/card grid
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonGrid extends StatelessWidget {
  final int count;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final double borderRadius;

  const SkeletonGrid({
    super.key,
    required this.count,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.82,
    this.spacing = 10,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < count; i += crossAxisCount) {
      final rowItems = <Widget>[];
      for (int j = 0; j < crossAxisCount; j++) {
        final idx = i + j;
        rowItems.add(Expanded(
          child: idx < count
              ? AspectRatio(
            aspectRatio: childAspectRatio,
            child: SkeletonBox(
                height: double.infinity,
                borderRadius: borderRadius),
          )
              : const SizedBox.shrink(),
        ));
        if (j < crossAxisCount - 1) rowItems.add(SizedBox(width: spacing));
      }
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowItems));
      if (i + crossAxisCount < count) rows.add(SizedBox(height: spacing));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. SKELETON CAROUSEL  — horizontal strip of cards
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonCarousel extends StatelessWidget {
  final double height;
  final int count;
  final double cardWidth;
  final double borderRadius;

  const SkeletonCarousel({
    super.key,
    required this.height,
    this.count = 3,
    this.cardWidth = 280,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: count,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => SkeletonBox(
              width: cardWidth,
              height: height,
              borderRadius: borderRadius,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Dots indicator skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
                (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SkeletonBox(
                  width: i == 0 ? 20 : 6, height: 6, borderRadius: 3),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. SKELETON SECTION  — labelled section: title + content widget
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonSection extends StatelessWidget {
  final Widget content;
  final EdgeInsetsGeometry padding;

  const SkeletonSection({
    super.key,
    required this.content,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding,
          child: SkeletonBox(width: 120, height: 18, borderRadius: 8),
        ),
        const SizedBox(height: 10),
        Padding(padding: padding, child: content),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 11. SKELETON PAGE  — full page layout: wraps everything in ShimmerScope
//     Pass a list of section widgets (use SkeletonSection / direct widgets).
// ─────────────────────────────────────────────────────────────────────────────
class SkeletonPage extends StatelessWidget {
  final List<Widget> sections;
  final EdgeInsetsGeometry titlePadding;

  const SkeletonPage({
    super.key,
    required this.sections,
    this.titlePadding = const EdgeInsets.fromLTRB(20, 16, 20, 8),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // Page title bar skeleton
            Padding(
              padding: titlePadding,
              child: SkeletonBox(width: 160, height: 28, borderRadius: 10),
            ),
            const SizedBox(height: 8),
            ...sections,
          ],
        ),
      ),
    );
  }
}