import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixco/features/home/pages/home.dart';
import 'package:fixco/features/contact/pages/contact.dart';
import 'package:fixco/features/about/pages/about.dart';
import 'package:fixco/features/booking/pages/booking.dart';
import 'package:fixco/features/profile/pages/profile_page.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/navigation/bottom_bar.dart';

// ─── Global key — lets any widget switch tabs from outside AppShell ───────────
final GlobalKey<AppShellState> appShellKey = GlobalKey<AppShellState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int currentIndex = 0;

  // ─── Public method — call appShellKey.currentState?.setTab(n) from anywhere ──
  void setTab(int index) {
    if (mounted && index >= 0 && index < 5) {
      setState(() => currentIndex = index);
    }
  }

  @override
  void initState() {
    super.initState();
    _initFCM();
    _setupForegroundListener();
    _setupNotificationClick();
  }

  // ─── FCM initialisation — handles iOS simulator (no APNS) gracefully ─────────
  Future<void> _initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // iOS simulator has no APNS token — skip to avoid crash
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) return; // running on simulator — bail early
      }

      final token = await messaging.getToken();
      if (token != null && UserSession.isLoggedIn()) {
        await Api.saveFCMToken(UserSession.userId!, token);
      }
    } catch (e) {
      // Silently swallow FCM errors (e.g. simulator, no network)
      debugPrint('FCM init skipped: $e');
    }
  }

  // ─── Foreground message listener (extend as needed) ──────────────────────────
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((_) {});
  }

  // ─── Notification tap → navigate to Bookings tab ─────────────────────────────
  void _setupNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      setState(() => currentIndex = 2);
    });
  }

  // ─── Internal shortcut used by HomePage's profile avatar ─────────────────────
  void _goToProfile() => setState(() => currentIndex = 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // extendBody allows page content to render behind the floating bottom bar
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomePage(onProfileTap: _goToProfile),
          const About(),
          const Booking(),
          const Contact(),
          const ProfilePage(),
        ],
      ),
      // BottomBar manages its own sizing — do NOT wrap in a Stack here
      bottomNavigationBar: BottomBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
