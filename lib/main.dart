import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';
import 'package:fixco/features/onboarding/controller/onboarding_controller.dart';
import 'package:fixco/features/onboarding/pages/get_started.dart';
import 'package:fixco/features/authentication/login/pages/login.dart';
import 'package:fixco/navigation/app_shell.dart';
import 'package:fixco/services/user_session.dart';

// ─── Firebase background message handler ────────────────────────────────────
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Uses DefaultFirebaseOptions so it works on both iOS and Android
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    debugPrint('Background Notification:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body:  ${message.notification?.body}');
  }
}

// ─── Entry point ─────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization must be ready before runApp
  await EasyLocalization.ensureInitialized();

  // DefaultFirebaseOptions handles both iOS (GoogleService-Info.plist) and Android (google-services.json)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await UserSession.loadUser();

  // Dev-only SSL bypass — remove before releasing to production
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

// ─── SSL bypass for dev environments ─────────────────────────────────────────
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// ─── Root app widget ──────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = OnboardingController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fixco',
      // Localization wired through EasyLocalization context extensions
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: '/',
      routes: {
        '/':      (context) => _LaunchRouter(controller),
        '/login': (context) => const LoginScreen(),
        '/app':   (context) => AppShell(key: appShellKey), // global key for external tab switching
      },
    );
  }
}

// ─── Launch router — onboarding vs main shell ─────────────────────────────────
class _LaunchRouter extends StatelessWidget {
  final OnboardingController controller;
  const _LaunchRouter(this.controller);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: controller.isFirstLaunch(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Something went wrong — show error with retry
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => (context as Element).reassemble(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // First launch → onboarding; returning user → main shell
        if (snapshot.data == true) return const GetStarted();
        return AppShell(key: appShellKey);
      },
    );
  }
}
