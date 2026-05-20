import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ProfileAppVersion extends StatelessWidget {
  const ProfileAppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('App Version'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: GlassCard(
          child: Center(
            child: Text(
              'App Version\n\nv1.0.0',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}