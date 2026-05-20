import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fixco/features/onboarding/controller/onboarding_controller.dart';
import '../../gradient_scaffold.dart'; // shared gradient background

// ============================================================================
// GLASS CARD (reused from other screens)
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
// GET STARTED SCREEN – glassmorphic design
// ============================================================================
class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with TickerProviderStateMixin {
  final OnboardingController controller = OnboardingController();

  // ── entrance animation ─────────────────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── logo glow / wave pulse ─────────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  late Animation<double> _wave1Anim;
  late Animation<double> _wave2Anim;
  late Animation<double> _wave3Anim;

  // ── floating arrow icon ────────────────────────────────────────────────────
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // ── orbs drift (subtle, white/grey) ───────────────────────────────────────
  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim;

  @override
  void initState() {
    super.initState();

    // entrance
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    // glow waves (3 expanding rings) – white tones
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _glowAnim = Tween<double>(begin: 0.85, end: 1.12)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _wave1Anim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut);
    _wave2Anim = CurvedAnimation(
      parent: _glowCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _wave3Anim = CurvedAnimation(
      parent: _glowCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    // floating arrow
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -4.0, end: 4.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // orb drift (white/grey soft orbs)
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _orbAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    // kick off entrance after a short delay
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GradientScaffold(
      body: Stack(
        children: [
          // animated orb background (white/grey translucent)
          _buildOrbBackground(size),
          // main content with entrance animations
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          _buildLogoSection(),
                          const SizedBox(height: 40),
                          _buildTextSection(),
                        ],
                      ),
                    ),
                    _buildBottomSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── orb background (soft white/grey circles) ──────────────────────────────
  Widget _buildOrbBackground(Size size) {
    return AnimatedBuilder(
      animation: _orbAnim,
      builder: (context, _) {
        final t = _orbAnim.value;
        return Stack(
          children: [
            Positioned(
              top: -60 + (t * 30),
              right: -80 + (t * 20),
              child: _orb(260, Colors.white.withOpacity(0.04)),
            ),
            Positioned(
              top: 80 - (t * 20),
              left: -60 + (t * 15),
              child: _orb(180, Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              bottom: -80 + (t * 25),
              left: -50 - (t * 10),
              child: _orb(300, Colors.white.withOpacity(0.03)),
            ),
            Positioned(
              bottom: 100 - (t * 30),
              right: -40 + (t * 20),
              child: _orb(200, Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              top: size.height * 0.45 + (t * 20),
              left: 20 - (t * 10),
              child: _orb(90, Colors.white.withOpacity(0.04)),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // ── logo with glow wave (white outlines) ───────────────────────────────────
  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // wave rings – white translucent
              _waveRing(
                progress: _wave3Anim.value,
                maxRadius: 108,
                color: Colors.white,
                opacity: (1 - _wave3Anim.value) * 0.12,
                strokeWidth: 1.2,
              ),
              _waveRing(
                progress: _wave2Anim.value,
                maxRadius: 90,
                color: Colors.white,
                opacity: (1 - _wave2Anim.value) * 0.18,
                strokeWidth: 1.6,
              ),
              _waveRing(
                progress: _wave1Anim.value,
                maxRadius: 74,
                color: Colors.white,
                opacity: (1 - _wave1Anim.value) * 0.25,
                strokeWidth: 2.0,
              ),
              // soft glow disc
              Transform.scale(
                scale: _glowAnim.value,
                child: Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.20),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // logo card – glass style
              child!,
            ],
          ),
        );
      },
      child: GlassCard(
        borderRadius: 34,
        padding: EdgeInsets.zero,
        hasBorder: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Image.asset(
            'assets/images/fixco.png',
            width: 124,
            height: 124,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 124,
              height: 124,
              color: Colors.white.withOpacity(0.08),
              child: const Icon(Icons.home_repair_service_rounded,
                  color: Colors.white70, size: 52),
            ),
          ),
        ),
      ),
    );
  }

  Widget _waveRing({
    required double progress,
    required double maxRadius,
    required Color color,
    required double opacity,
    required double strokeWidth,
  }) {
    final radius = maxRadius * progress;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(opacity.clamp(0.0, 1.0)),
          width: strokeWidth,
        ),
      ),
    );
  }

  // ── text section – white on glass ─────────────────────────────────────────
  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          // pill badge – glass style
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            borderRadius: 50,
            hasBorder: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Trusted Maintenance Services',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            'Your all-in-one maintenance solution.\nFast, reliable, and trusted service\ndelivered right to your door.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.70),
              height: 1.65,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── bottom section with CTA button ─────────────────────────────────────────
  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // subtle divider hint
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: 48,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // CTA button – glass card with white text
          SizedBox(
            width: double.infinity,
            height: 62,
            child: GlassCard(
              borderRadius: 20,
              onTap: () async {
                await controller.completeOnboarding();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/app');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_floatAnim.value, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Developed by MEDCO – subtle white
          Text(
            'Developed by MEDCO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.30),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}