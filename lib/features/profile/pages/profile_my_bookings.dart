import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ProfileMyBookings extends StatelessWidget {
  const ProfileMyBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: GlassCard(
          child: Center(
            child: Text(
              'My Bookings\n\nComing Soon',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}