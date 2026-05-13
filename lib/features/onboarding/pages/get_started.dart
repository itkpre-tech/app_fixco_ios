import 'package:flutter/material.dart';
import 'package:fixco/features/onboarding/controller/onboarding_controller.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted>
    with TickerProviderStateMixin {
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

  // ── orbs drift ────────────────────────────────────────────────────────────
  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim; // 0.0 → 1.0

  // ── brand colours ──────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFFE65100);      // deep orange
  static const Color _primaryLight = Color(0xFFFF8A50); // soft orange
  static const Color _accent = Color(0xFFFF6D2D);        // mid orange
  static const Color _bgColor = Color(0xFFFFFBF8);       // warm white

  @override
  void initState() {
    super.initState();

    // entrance
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    // glow waves (3 expanding rings)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _glowAnim = Tween<double>(begin: 0.85, end: 1.12).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _wave1Anim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut);
    _wave2Anim = CurvedAnimation(
        parent: _glowCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
    _wave3Anim = CurvedAnimation(
        parent: _glowCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut));

    // floating arrow
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // orb drift — Tween.animate() ensures late Animation<double> is satisfied
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _orbAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

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

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ── animated orb background ──────────────────────────────────────
          _buildOrbBackground(size),

          // ── main content ─────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // top spacer + logo
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

                    // bottom pinned section
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

  // ── orb background ─────────────────────────────────────────────────────────

  Widget _buildOrbBackground(Size size) {
    return AnimatedBuilder(
      animation: _orbAnim,
      builder: (context, _) {
        final t = _orbAnim.value;
        return Stack(
          children: [
            // top-right large orb
            Positioned(
              top: -60 + (t * 30),
              right: -80 + (t * 20),
              child: _orb(260, _primary.withValues(alpha: 0.08)),
            ),
            // top-left small orb
            Positioned(
              top: 80 - (t * 20),
              left: -60 + (t * 15),
              child: _orb(180, _primaryLight.withValues(alpha: 0.10)),
            ),
            // bottom-left large orb
            Positioned(
              bottom: -80 + (t * 25),
              left: -50 - (t * 10),
              child: _orb(300, _accent.withValues(alpha: 0.07)),
            ),
            // bottom-right mid orb
            Positioned(
              bottom: 100 - (t * 30),
              right: -40 + (t * 20),
              child: _orb(200, _primaryLight.withValues(alpha: 0.09)),
            ),
            // center-left tiny accent
            Positioned(
              top: size.height * 0.45 + (t * 20),
              left: 20 - (t * 10),
              child: _orb(90, _primary.withValues(alpha: 0.06)),
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

  // ── logo with glow wave ────────────────────────────────────────────────────

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
              // wave 3 — outermost, earliest fade
              _waveRing(
                progress: _wave3Anim.value,
                maxRadius: 108,
                color: _primary,
                opacity: (1 - _wave3Anim.value) * 0.18,
                strokeWidth: 1.2,
              ),
              // wave 2
              _waveRing(
                progress: _wave2Anim.value,
                maxRadius: 90,
                color: _primary,
                opacity: (1 - _wave2Anim.value) * 0.28,
                strokeWidth: 1.6,
              ),
              // wave 1 — innermost
              _waveRing(
                progress: _wave1Anim.value,
                maxRadius: 74,
                color: _primary,
                opacity: (1 - _wave1Anim.value) * 0.40,
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
                        _primaryLight.withValues(alpha: 0.30),
                        _primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // logo card
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: 124,
        height: 124,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.22),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Image.asset(
            'assets/images/fixco.png',
            width: 124,
            height: 124,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                color: const Color(0xFFFFF3EE),
              ),
              child: const Center(
                child: Icon(
                  Icons.home_repair_service_rounded,
                  color: _primary,
                  size: 52,
                ),
              ),
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
          color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
          width: strokeWidth,
        ),
      ),
    );
  }

  // ── text section ───────────────────────────────────────────────────────────

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          // pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _primary.withValues(alpha: 0.18), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Trusted Maintenance Services',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // headline
          const Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A0A00),
              letterSpacing: -0.5,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // description — bigger, warmer
          Text(
            'Your all-in-one maintenance solution.\nFast, reliable, and trusted service\ndelivered right to your door.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A0A00).withValues(alpha: 0.55),
              height: 1.65,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── bottom pinned section ──────────────────────────────────────────────────

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
              color: _primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // CTA button
          SizedBox(
            width: double.infinity,
            height: 62,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _accent, _primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.38),
                    blurRadius: 22,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await controller.completeOnboarding();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/app');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
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
                    // floating arrow icon
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
                          color: Colors.white.withValues(alpha: 0.22),
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
          ),

          const SizedBox(height: 24),

          // Developed by MEDCO
          Text(
            'Developed by MEDCO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A0A00).withValues(alpha: 0.30),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}