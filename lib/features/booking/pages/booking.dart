import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/features/authentication/login/pages/login.dart';
import 'package:fixco/features/booking/pages/booking_details.dart';

class BookingModel {
  final int id;
  final String service;
  final String dateTime;
  final String status;
  final Map<String, dynamic> raw;

  BookingModel({
    required this.id,
    required this.service,
    required this.dateTime,
    required this.status,
    required this.raw,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: int.parse(json['id'].toString()),
      service: json['service_name'] ?? 'Service',
      dateTime:
      "${json['booking_date_formatted']} • ${json['booking_time_formatted']}",
      status: _formatStatus(json['status']),
      raw: json,
    );
  }

  static String _formatStatus(String? status) {
    if (status == null) return "Pending";
    return "${status[0].toUpperCase()}${status.substring(1)}";
  }
}

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  int selectedIndex = 0;

  final tabs = ["Pending", "Confirmed", "Completed", "Cancelled"];

  final icons = [
    Icons.hourglass_bottom,
    Icons.verified,
    Icons.check_circle,
    Icons.cancel,
  ];

  List<BookingModel> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await UserSession.loadUser();
    await fetchBookings();
  }

  Future<void> fetchBookings() async {
    if (!UserSession.isLoggedIn()) {
      setState(() => isLoading = false);
      return;
    }

    final data = await Api.getUserBookings(UserSession.userId!);

    if (!mounted) return;

    setState(() {
      bookings = data.map((e) => BookingModel.fromJson(e)).toList();
      isLoading = false;
    });
  }

  List<BookingModel> get filtered {
    return bookings
        .where((b) =>
    b.status.toLowerCase() == tabs[selectedIndex].toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = !UserSession.isLoggedIn();

    return Scaffold(
      backgroundColor: Colors.black,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () {
          if (isGuest) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          }
        },
        label: Text(isGuest ? "Login to Book" : "Book Now"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 50),

          const Text(
            "My Bookings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (_, i) {
                final selected = selectedIndex == i;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = i);
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.red : Colors.white10,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icons[i],
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tabs[i],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),
          Expanded(
            child: buildList(isGuest),
          ),
        ],
      ),
    );
  }

  Widget buildList(bool isGuest) {
    if (isGuest) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text("Login to Continue"),
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No bookings",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (_, i) => BookingCard(
          booking: filtered[i],
          onCancel: () async {
            await Api.cancelBooking(filtered[i].id);
            fetchBookings();
          },
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  Color getColor() {
    switch (booking.status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "confirmed":
        return Colors.blue;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status.toLowerCase() == "pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.service,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.dateTime,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.status,
                        style: TextStyle(color: getColor()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Divider(color: Colors.white12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingDetails(data: booking.raw),
                          ),
                        );
                      },
                      child: const Text(
                        "View Details",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    if (isPending)
                      TextButton(
                        onPressed: onCancel,
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}