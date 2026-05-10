import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/features/authentication/register/pages/register.dart';
import 'package:fixco/features/authentication/login/pages/login_success.dart';
import 'package:fixco/features/authentication/login/pages/login_error.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<String?> getFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Request permission first
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('Notification permission denied');
        return null;
      }
      
      // On iOS, wait for APNS token to be registered
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        print('Waiting for APNS token on iOS...');
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Get the token with retry logic
      String? token;
      int retries = 0;
      while (token == null && retries < 3) {
        token = await messaging.getToken();
        if (token == null) {
          print('Retry ${retries + 1} - waiting for token...');
          await Future.delayed(const Duration(milliseconds: 500));
          retries++;
        }
      }
      
      if (token != null) {
        print('FCM Token obtained: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      } else {
        print('Failed to get FCM token after retries');
      }
      
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await Api.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['status'] == 'success') {
      final user = response['user'];

      await UserSession.saveUser(
        id: int.parse(user['id'].toString()),
        name: user['name'],
        email: user['email'],
      );

      if (!mounted) return;

      // Save token in background (don't wait for it)
      _saveFCMToken(user['id']);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginSuccessPage(user: user)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LoginErrorPage(message: response['message'] ?? "Login failed"),
        ),
      );
    }
  }
  
  Future<void> _saveFCMToken(int userId) async {
    final String? token = await getFCMToken();
    if (token != null && mounted) {
      await Api.saveFCMToken(userId, token);
      print('FCM token saved for user $userId');
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1C1C1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white38),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to continue",
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return "Enter email";
                  if (!value.contains("@")) return "Enter valid email";
                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Enter password";
                  if (value.length < 6) return "Minimum 6 characters";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}