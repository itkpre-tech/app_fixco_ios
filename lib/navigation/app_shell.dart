import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixco/features/home/pages/home.dart';
import 'package:fixco/features/contact/pages/contact.dart';
import 'package:fixco/features/about/pages/about.dart';
import 'package:fixco/features/booking/pages/booking.dart';
import 'package:fixco/features/profile/pages/profile_page.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/navigation/bottom_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initFCM();
    setupForegroundListener();
    setupNotificationClick();
  }

  Future<void> initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // iOS simulator doesn't support APNS so we skip token fetch
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) return; // simulator — skip
      }

      String? token = await messaging.getToken();
      if (token != null && UserSession.isLoggedIn()) {
        await Api.saveFCMToken(UserSession.userId!, token);
      }
    } catch (e) {
      // silently ignore FCM errors on simulator
      debugPrint('FCM init skipped: $e');
    }
  }

  void setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  }

  void setupNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        currentIndex = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: [  // ✅ Removed 'const' keyword
          HomePage(),
          const About(),  // Keep const if About widget has const constructor
          Booking(),
          Contact(),
          ProfilePage(),  // ✅ Changed from Profile() to ProfilePage()
        ],
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}