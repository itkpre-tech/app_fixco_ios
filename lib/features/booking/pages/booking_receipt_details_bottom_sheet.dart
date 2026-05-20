import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'booking.dart'; // Import BookingModel

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
// Custom glass container for special borders (cancellation only)
// ============================================================================
class CustomGlassContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;

  const CustomGlassContainer({
    super.key,
    required this.child,
    required this.borderColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// RECEIPT BOTTOM SHEET – with 100% initial size, snap to 25/50/75/100
// No notes, no admin replies – only core booking details
// ============================================================================
class BookingReceiptDetailsBottomSheet extends StatelessWidget {
  final BookingModel booking;

  const BookingReceiptDetailsBottomSheet({super.key, required this.booking});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
      initialChildSize: 1.0,       // start at 100%
      minChildSize: 0.25,          // can go down to 25%
      maxChildSize: 1.0,           // max 100%
      snap: true,
      snapSizes: const [0.25, 0.5, 0.75, 1.0],
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
                child: const CustomPaint(painter: _TopWavePainter()),
              ),
              // Bottom wave overlay
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
                  // Header with title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Booking Receipt',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
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
                  const SizedBox(height: 12),
                  // Scrollable receipt content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store header
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long, size: 48, color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'FIXCO',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Service Receipt',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Booking ID (with copy)
                            _buildReceiptRow(
                              'Booking ID',
                              '#${booking.id}',
                              onCopy: () => _copyToClipboard(context, booking.id.toString(), 'Booking ID'),
                            ),
                            const Divider(height: 16, color: Colors.white24),

                            // Service details
                            _buildReceiptRow('Service', booking.serviceName),
                            if (booking.subServiceName.isNotEmpty)
                              _buildReceiptRow('Sub-Service', booking.subServiceName),
                            if (booking.categoryName.isNotEmpty)
                              _buildReceiptRow('Category', booking.categoryName),
                            const SizedBox(height: 8),

                            // Booking date & time
                            _buildReceiptRow('Date', _formatDateOnly(booking.raw['booking_date'])),
                            _buildReceiptRow('Time', booking.raw['booking_time'] ?? '—'),
                            const SizedBox(height: 8),

                            // Amount
                            GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
                                  ),
                                  Text(
                                    '${booking.amount.toStringAsFixed(2)} AED',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Payment details
                            _buildReceiptRow('Payment Method', booking.raw['payment_method']?.toString().toUpperCase() ?? '—'),
                            _buildReceiptRow(
                              'Payment Status',
                              booking.paymentStatus.toUpperCase(),
                              valueColor: booking.paymentStatus.toLowerCase() == 'paid' ? Colors.green : Colors.orange,
                            ),
                            if (booking.raw['transaction_id'] != null &&
                                booking.raw['transaction_id'].toString().isNotEmpty)
                              _buildReceiptRow(
                                'Transaction ID',
                                booking.raw['transaction_id'],
                                onCopy: () => _copyToClipboard(context, booking.raw['transaction_id'], 'Transaction ID'),
                              ),
                            if (booking.raw['payment_date'] != null)
                              _buildReceiptRow('Payment Date', _formatDateTime(booking.raw['payment_date'])),

                            const SizedBox(height: 16),
                            const Divider(height: 1, thickness: 1, color: Colors.white24),

                            // Booking status
                            _buildReceiptRow('Booking Status', booking.status.toUpperCase(), valueColor: _statusColor(booking.status)),
                            const SizedBox(height: 8),

                            // Cancellation details (with red border) – only if cancelled
                            if (booking.status.toLowerCase() == 'cancelled') ...[
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cancellation Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  CustomGlassContainer(
                                    borderColor: Colors.red.withOpacity(0.5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (booking.raw['cancellation_reason'] != null)
                                            Text(
                                              'Reason: ${booking.raw['cancellation_reason']}',
                                              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                            ),
                                          if (booking.raw['cancelled_by'] != null)
                                            Text(
                                              'Cancelled by: ${booking.raw['cancelled_by']}',
                                              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                            ),
                                          if (booking.raw['cancelled_at'] != null)
                                            Text(
                                              'Date: ${_formatDateTime(booking.raw['cancelled_at'])}',
                                              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Thank you for choosing Fixco!',
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                              ),
                            ),
                            const SizedBox(height: 20),
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

  Widget _buildReceiptRow(
      String label,
      String value, {
        Color? valueColor,
        VoidCallback? onCopy,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.copy, size: 14, color: Colors.white.withOpacity(0.7)),
                ],
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}