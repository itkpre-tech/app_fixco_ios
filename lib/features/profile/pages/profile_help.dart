import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileHelp extends StatelessWidget {
  const ProfileHelp({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : Colors.white,
      appBar: AppBar(
        title: Text('help'.tr()),
        backgroundColor: isDark ? const Color(0xFF1A1C22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'help_content_placeholder'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}