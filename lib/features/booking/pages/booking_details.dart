import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';

class BookingDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const BookingDetails({super.key, required this.data});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    final data = bookingData ?? widget.data;
    final status = (data['status'] ?? "pending").toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
        onRefresh: fetchLatest,
        color: Colors.white,
        backgroundColor: Colors.black54,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['service_name'] ?? "Service",
                      style: const TextStyle(
                        color: Colors.white,
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
              _glassCard(
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (status.toLowerCase() == "pending")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await Api.cancelBooking(
                        int.parse(data['id'].toString()),
                      );
                      await fetchLatest();
                    },
                    child: const Text("Cancel Booking"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            value ?? "-",
            style: const TextStyle(
              color: Colors.white,
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
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
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
        color = Colors.green;
        break;
      case "confirmed":
        color = Colors.blue;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}