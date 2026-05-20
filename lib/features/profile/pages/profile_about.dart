import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ProfileAbout extends StatelessWidget {
  const ProfileAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: GlassCard(
          child: Center(
            child: Text(
              'About\n\nComing Soon',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}