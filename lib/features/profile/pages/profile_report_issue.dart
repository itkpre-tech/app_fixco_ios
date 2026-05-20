import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ProfileReportIssue extends StatelessWidget {
  const ProfileReportIssue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Report Issue'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: GlassCard(
          child: Center(
            child: Text(
              'Report Issue\n\nComing Soon',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}