import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

// ─── Theme colours ────────────────────────────────────────────────────────────
const Color _activeColor   = Color(0xFFD32F2F);
const Color _inactiveColor = Color(0xFF9E9E9E);
const Color _dropColor     = Color(0xFFD32F2F);

// ─── Nav item definition ──────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  const _NavItem({required this.icon});
}

const List<_NavItem> _navItems = [
  _NavItem(icon: HugeIcons.strokeRoundedHome01),
  _NavItem(icon: HugeIcons.strokeRoundedCompass),
  _NavItem(icon: HugeIcons.strokeRoundedCalendar01), // centre action button
  _NavItem(icon: HugeIcons.strokeRoundedHeadphones),
  _NavItem(icon: HugeIcons.strokeRoundedUser),
];

// ─── Ripple painter for the centre booking button ─────────────────────────────
class _RipplePainter extends CustomPainter {
  final double ripple;
  const _RipplePainter({required this.ripple});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r  = 24.0;

    // Solid circle background
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [_dropColor, _dropColor.withOpacity(0.75)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Animated ripple ring
    if (ripple > 0.04) {
      canvas.drawCircle(
        Offset(cx, cy),
        r + ripple * 14,
        Paint()
          ..color       = _dropColor.withOpacity((1.0 - ripple).clamp(0.0, 1.0) * 0.26)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter o) => o.ripple != ripple;
}

// ─── BottomBar ────────────────────────────────────────────────────────────────
class BottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _rippleCtrl;
  Animation<double>?   _rippleAnim;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _rippleCtrl = ctrl;
    _rippleAnim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    ctrl.repeat(); // continuous pulse on centre button
  }

  @override
  void dispose() {
    _rippleCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make system nav bar transparent so the pill floats above it
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ));

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final screenW    = MediaQuery.of(context).size.width;

    // Pill width: 68 % of screen, clamped for very small/large screens
    final pillW = (screenW * 0.68).clamp(280.0, 380.0);

    return SizedBox(
      width:  screenW,
      height: 58 + 28 + safeBottom, // pill height + top margin + safe-area
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: safeBottom),
          child: _buildPill(pillW),
        ),
      ),
    );
  }

  // ─── Frosted glass pill ───────────────────────────────────────────────────
  Widget _buildPill(double pillW) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width:  pillW,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset:     const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (i) {
              final isActive = widget.currentIndex == i;
              // Centre button gets special ripple treatment
              if (i == 2) return _buildCenterButton(i, isActive);
              return _NavButton(
                key:      ValueKey(i),
                item:     _navItems[i],
                isActive: isActive,
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onTap(i);
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─── Pulsing centre action button ────────────────────────────────────────
  Widget _buildCenterButton(int idx, bool isActive) {
    final ctrl = _rippleCtrl;

    Widget content({double ripple = 0}) => SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(50, 50),
            painter: _RipplePainter(ripple: ripple),
          ),
          HugeIcon(
            icon:  _navItems[idx].icon,
            color: Colors.white,
            size:  20.0,
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap(idx);
      },
      child: SizedBox(
        width:  50,
        height: 58,
        child: Center(
          child: ctrl == null
              ? content()
              : AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) => content(ripple: _rippleAnim?.value ?? 0),
          ),
        ),
      ),
    );
  }
}

// ─── Individual nav button ────────────────────────────────────────────────────
class _NavButton extends StatefulWidget {
  final _NavItem     item;
  final bool         isActive;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>?   _scale;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _ctrl = ctrl;
    // Bounce sequence: grow → overshoot → settle
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0,  end: 1.26), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.26, end: 0.91), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.91, end: 1.0),  weight: 35),
    ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));

    if (widget.isActive) ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(_NavButton old) {
    super.didUpdateWidget(old);
    // Trigger bounce when this tab becomes active
    if (widget.isActive && !old.isActive) _ctrl?.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl  = _ctrl;
    final scale = _scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: ctrl ?? const AlwaysStoppedAnimation(0),
        builder: (_, child) => Transform.scale(
          scale: (widget.isActive && scale != null) ? scale.value : 1.0,
          child: child,
        ),
        child: SizedBox(
          width:  42,
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon:  widget.item.icon,
                color: widget.isActive ? _activeColor : _inactiveColor,
                size:  20.0,
              ),
              const SizedBox(height: 5),
              // Active indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width:  widget.isActive ? 4 : 0,
                height: widget.isActive ? 4 : 0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _activeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PageBody — use as the body wrapper on every page ────────────────────────
// Automatically adds bottom padding so content clears the floating pill bar.
class PageBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PageBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    // 28 = top margin above pill, 58 = pill height, 16 = extra breathing room
    final bottomInset = MediaQuery.of(context).padding.bottom + 28 + 58 + 16;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: padding.add(EdgeInsets.only(bottom: bottomInset)),
            child: child,
          ),
        ),
      ),
    );
  }
}
