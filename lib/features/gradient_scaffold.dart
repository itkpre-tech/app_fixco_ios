import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final BottomNavigationBar? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.50, 1.0],
          colors: [
            Color(0xFF1C0404),
            Color(0xFF6B1010),
            Color(0xFF1C0404),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Single top wave ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.22,
            child: CustomPaint(painter: _TopWavePainter()),
          ),

          // ── Single bottom wave ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.22,
            child: CustomPaint(painter: _BottomWavePainter()),
          ),

          // ── Scaffold ────────────────────────────────────────────────────
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: body,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP WAVE
// One single smooth arc that sweeps down from the top edge — like a hood.
// Dark crimson, barely visible, no fill on the sky above.
// ============================================================================
class _TopWavePainter extends CustomPainter {
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

// ============================================================================
// BOTTOM WAVE
// One single smooth arc that rises from the bottom edge — a mirror feel.
// Slightly lighter dark red so it's distinct from the top.
// ============================================================================
class _BottomWavePainter extends CustomPainter {
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