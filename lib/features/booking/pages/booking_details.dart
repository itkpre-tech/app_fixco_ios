import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import '../../home/shared/home_constants.dart'; // provides kPrimary, kTextDark, kTextLight

// ---------------------------------------------------------------------
// Global color constants (formal white/black theme)
// ---------------------------------------------------------------------
const Color _black87 = Color(0xDD000000);
const Color _black54 = Color(0x8A000000);
const Color _grey200 = Color(0xFFE0E0E0);
const Color _grey50 = Color(0xFFFAFAFA);

class BookingDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const BookingDetails({super.key, required this.data});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;
  bool isCancelling = false;

  @override
  void initState() {
    super.initState();
    bookingData = widget.data;
    fetchLatest();
  }

  Future<void> fetchLatest() async {
    if (!UserSession.isLoggedIn()) return;

    final list = await Api.getUserBookings(UserSession.userId!);
    final updated = list.firstWhere(
          (b) => b['id'].toString() == widget.data['id'].toString(),
      orElse: () => bookingData,
    );

    if (mounted) {
      setState(() {
        bookingData = updated;
        isLoading = false;
      });
    }
  }

  Future<void> handleCancelBooking() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => _CancelDialog(booking: bookingData!),
    );

    if (shouldCancel != true) return;

    setState(() => isCancelling = true);

    final result = await Api.cancelBooking(
      bookingId: int.parse(bookingData!['id'].toString()),
      userId: UserSession.userId!,
      reason: 'Cancelled by user from details page',
    );

    if (!mounted) return;

    setState(() => isCancelling = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await fetchLatest();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to cancel booking'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    await fetchLatest();
  }

  @override
  Widget build(BuildContext context) {
    final data = bookingData ?? widget.data;
    final status = (data['status'] ?? "pending").toString();
    final isPending = status.toLowerCase() == "pending";
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: kPrimary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingDetailsTitleBar(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isLoading
                    ? const Center(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: kPrimary)),
                  ),
                )
                    : Column(
                  children: [
                    _infoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['service_name'] ?? "Service",
                            style: const TextStyle(
                              color: _black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _statusBadge(status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow(
                            icon: Icons.calendar_today,
                            title: "Date",
                            value: data['booking_date_formatted'],
                          ),
                          const SizedBox(height: 14),
                          _buildRow(
                            icon: Icons.access_time,
                            title: "Time",
                            value: data['booking_time_formatted'],
                          ),
                          const SizedBox(height: 14),
                          _buildNotesRow(
                            icon: Icons.note,
                            title: "Notes",
                            value: data['notes'] ?? "-",
                          ),
                          if (data['cancellation_reason'] != null &&
                              status.toLowerCase() == "cancelled") ...[
                            const SizedBox(height: 14),
                            _buildNotesRow(
                              icon: Icons.info_outline,
                              title: "Cancellation Reason",
                              value: data['cancellation_reason'],
                            ),
                            const SizedBox(height: 14),
                            _buildRow(
                              icon: Icons.access_time,
                              title: "Cancelled At",
                              value: data['cancelled_at'] ?? "-",
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isPending && !isCancelling)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: handleCancelBooking,
                          child: const Text("Cancel Booking"),
                        ),
                      ),
                    if (isCancelling)
                      const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _grey50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required String? value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _black54, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: _black54, fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            value ?? "-",
            style: const TextStyle(
              color: _black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesRow({
    required IconData icon,
    required String title,
    required String? value,
  }) {
    final displayValue = value ?? "-";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _black54, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: _black54, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                displayValue,
                style: const TextStyle(
                  color: _black87,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "completed":
        color = const Color(0xFF2E7D32);
        break;
      case "confirmed":
        color = const Color(0xFF1565C0);
        break;
      case "cancelled":
        color = const Color(0xFFC62828);
        break;
      default:
        color = kPrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Title bar with back button on the RIGHT side (keep title on left)
// ---------------------------------------------------------------------
class _BookingDetailsTitleBar extends StatelessWidget {
  final VoidCallback onBack;

  const _BookingDetailsTitleBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: brand chip + title + subtitle (unchanged)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kPrimary.withValues(alpha: 0.22), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: kPrimary),
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
                    'Booking Details',
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
                    'View and manage your appointment',
                    style: TextStyle(color: kTextLight, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Back button on the right
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _grey200, width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios, size: 18, color: _black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Cancel Dialog
// ---------------------------------------------------------------------
class _CancelDialog extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _CancelDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _grey200),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
          const SizedBox(width: 8),
          const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.w700, color: _black87)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to cancel this booking?', style: TextStyle(color: _black87)),
          const SizedBox(height: 8),
          Text('Service: ${booking['service_name'] ?? 'service'}', style: const TextStyle(fontWeight: FontWeight.w600, color: _black87)),
          const Text('This action cannot be undone.', style: TextStyle(color: _black54, fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep Booking', style: TextStyle(color: _black87)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Yes, Cancel'),
        ),
      ],
    );
  }
}