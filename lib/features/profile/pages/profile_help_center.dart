import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ProfileHelpCenter extends StatelessWidget {
  const ProfileHelpCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: GlassCard(
          child: Center(
            child: Text(
              'Help Center\n\nComing Soon',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}