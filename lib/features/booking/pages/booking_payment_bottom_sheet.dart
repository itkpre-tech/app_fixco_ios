import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';

// ============================================================================
// WAVE PAINTERS (same as GradientScaffold / sub_services_bottom_sheet)
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
// GLASS CARD (identical to sub_services_bottom_sheet)
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
// SVG ICON (fixed drawing for 'cash' and 'card')
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
      child: CustomPaint(painter: _SvgPainter(svgPath, size)),
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
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = sz.width / 24;
    final centerX = 12 * s;
    final centerY = 12 * s;

    switch (id) {
      case 'cash':
      // Money bag / bill icon: rectangle with dollar sign
        final rect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 12 * s,
          height: 14 * s,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(2 * s)),
          paint,
        );
        // Dollar sign
        final dollarPath = Path()
          ..moveTo(12 * s, 6 * s)
          ..lineTo(12 * s, 18 * s)
          ..moveTo(9 * s, 9 * s)
          ..cubicTo(9 * s, 8 * s, 10.5 * s, 7 * s, 12 * s, 7 * s)
          ..cubicTo(13.5 * s, 7 * s, 15 * s, 8 * s, 15 * s, 9 * s)
          ..cubicTo(15 * s, 10 * s, 14 * s, 10.5 * s, 12 * s, 11 * s)
          ..cubicTo(10 * s, 11.5 * s, 9 * s, 12.5 * s, 9 * s, 14 * s)
          ..cubicTo(9 * s, 15.5 * s, 10.5 * s, 17 * s, 12 * s, 17 * s)
          ..cubicTo(13.5 * s, 17 * s, 15 * s, 15.5 * s, 15 * s, 14 * s);
        canvas.drawPath(dollarPath, paint);
        break;

      case 'card':
      // Credit card shape
        final rect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 16 * s,
          height: 12 * s,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(2 * s)),
          paint,
        );
        // Magnetic stripe lines
        canvas.drawLine(Offset(6 * s, 9 * s), Offset(18 * s, 9 * s), paint);
        canvas.drawLine(Offset(8 * s, 13 * s), Offset(13 * s, 13 * s), paint);
        break;

      case 'send':
        final send = Path()
          ..moveTo(3 * s, 12 * s)
          ..lineTo(21 * s, 3 * s)
          ..lineTo(12 * s, 21 * s)
          ..lineTo(9 * s, 15 * s)
          ..lineTo(15 * s, 9 * s)
          ..lineTo(9 * s, 12 * s);
        canvas.drawPath(send, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
}

// ============================================================================
// PAYMENT BOTTOM SHEET – with 100% initial size and 25%, 50%, 75%, 100% snaps
// ============================================================================
class BookingPaymentBottomSheet extends StatefulWidget {
  final List<int> bookingIds;
  final double totalAmount;
  final VoidCallback onSuccess;

  const BookingPaymentBottomSheet({
    super.key,
    required this.bookingIds,
    required this.totalAmount,
    required this.onSuccess,
  });

  @override
  State<BookingPaymentBottomSheet> createState() =>
      _BookingPaymentBottomSheetState();
}

class _BookingPaymentBottomSheetState extends State<BookingPaymentBottomSheet> {
  String _selectedMethod = 'cash';
  bool _isProcessing = false;
  String? _error;

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

    return DraggableScrollableSheet(
      initialChildSize: 1.0,        // start at 100%
      minChildSize: 0.25,           // can shrink to 25%
      maxChildSize: 1.0,            // max 100%
      snap: true,                   // snap to nearest size
      snapSizes: const [0.25, 0.5, 0.75, 1.0], // snap points
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.22,
                child: const CustomPaint(painter: _TopWavePainter()),
              ),
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: const Text(
                            'Select Payment Method',
                            style: TextStyle(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cash option (enabled)
                            GlassCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              onTap: () => setState(() => _selectedMethod = 'cash'),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'cash',
                                    groupValue: _selectedMethod,
                                    onChanged: (val) => setState(() => _selectedMethod = val!),
                                    fillColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return Colors.red[800];
                                      }
                                      return Colors.white54;
                                    }),
                                  ),
                                  const _SvgIcon('cash', size: 24),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Cash on Delivery',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Card option (disabled)
                            GlassCard(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'card',
                                    groupValue: _selectedMethod,
                                    onChanged: null,
                                    fillColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return Colors.red[800];
                                      }
                                      return Colors.white24;
                                    }),
                                  ),
                                  const _SvgIcon('card', size: 24),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Card Payment (coming soon)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Total amount
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '${widget.totalAmount.toStringAsFixed(2)} AED',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_error != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: _isProcessing ? null : _pay,
                                child: GlassCard(
                                  borderRadius: 30,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isProcessing)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white70,
                                          ),
                                        )
                                      else ...[
                                        const _SvgIcon('send', size: 18),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Confirm Payment',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
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

  Future<void> _pay() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final result = await Api.processPayments(
      userId: UserSession.userId!,
      bookingIds: widget.bookingIds,
      paymentMethod: _selectedMethod,
      transactionId: null,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result['status'] == 'success') {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Payment successful!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _error = result['message'] ?? 'Payment failed. Please try again.');
    }
  }
}