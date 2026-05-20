import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/features/authentication/register/pages/register.dart';
import 'package:fixco/features/authentication/forgot/forgot_password.dart';
import 'package:fixco/navigation/app_shell.dart';
import '../../../gradient_scaffold.dart';

// ============================================================================
// PASSWORD STRENGTH ENUM
// ============================================================================
enum PasswordStrength { none, weak, medium, strong }

// ============================================================================
// LOGIN SCREEN
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Error messages
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _generalError;

  // Password strength
  double _passwordStrength = 0.0;
  PasswordStrength _strengthLevel = PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);
    setState(() {
      _passwordStrength = strength['score'];
      _strengthLevel = strength['level'];
    });
  }

  Map<String, dynamic> _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return {'score': 0.0, 'level': PasswordStrength.none};
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    double strengthScore = score / 7.0;
    PasswordStrength level;

    if (strengthScore < 0.3) {
      level = PasswordStrength.weak;
    } else if (strengthScore < 0.6) {
      level = PasswordStrength.medium;
    } else {
      level = PasswordStrength.strong;
    }

    return {'score': strengthScore.clamp(0.0, 1.0), 'level': level};
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include at least 1 uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Include at least 1 lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least 1 number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Include at least 1 special character';
    return null;
  }

  Future<String?> _getFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      return await messaging.getToken();
    } catch (e) {
      debugPrint('FCM Token error: $e');
      return null;
    }
  }

  Future<void> _login() async {
    setState(() {
      _emailErrorMessage = null;
      _passwordErrorMessage = null;
      _generalError = null;
    });

    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _emailErrorMessage = emailError);
      return;
    }

    final passwordError = _validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _passwordErrorMessage = passwordError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Api.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        final user = response['user'];
        await UserSession.saveUser(
          id: int.parse(user['id'].toString()),
          name: user['name'],
          email: user['email'],
        );

        final String? token = await _getFCMToken();
        if (token != null && mounted) {
          await Api.saveFCMToken(user['id'], token);
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
        );
      } else {
        setState(() {
          _generalError = response['message'] ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _generalError = 'Network error. Please check your connection.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _enterAsGuest() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  void _openForgotPassword() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          prefillEmail: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        ),
      ),
    );
  }

  // Glass input field (matches contact page form fields)
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? errorText,
    VoidCallback? onToggleVisibility,
    bool showVisibilityToggle = false,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? Colors.redAccent
                  : Colors.white.withOpacity(0.18),
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 13),
              prefixIcon: Icon(
                icon,
                color: hasError ? Colors.redAccent : Colors.white.withOpacity(0.55),
                size: 19,
              ),
              suffixIcon: showVisibilityToggle
                  ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white.withOpacity(0.55),
                  size: 18,
                ),
                onPressed: onToggleVisibility,
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              errorText: null,
            ),
            onChanged: (_) {
              if (hasError && mounted) {
                setState(() {
                  if (controller == _emailController) _emailErrorMessage = null;
                  if (controller == _passwordController) _passwordErrorMessage = null;
                });
              }
            },
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Color _getStrengthColor() {
    switch (_strengthLevel) {
      case PasswordStrength.weak:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
      default:
        return Colors.white.withOpacity(0.2);
    }
  }

  String _getStrengthText() {
    switch (_strengthLevel) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FIXCO Logo / Title
                  const Text(
                    'FIXCO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xCCFFFFFF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  _buildGlassTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    errorText: _emailErrorMessage,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildGlassTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    errorText: _passwordErrorMessage,
                    showVisibilityToggle: true,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 8),

                  // Password Strength Meter
                  if (_passwordController.text.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStrengthText(),
                          style: TextStyle(
                            color: _getStrengthColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openForgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // General Error
                  if (_generalError != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _generalError!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Login Button – glass card style
                  GestureDetector(
                    onTap: _isLoading ? null : _login,
                    child: GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            )
                          else ...[
                            const Icon(Icons.login_rounded, color: Colors.white70, size: 18),
                            const SizedBox(width: 10),
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Guest Mode Button – outlined glass card
                  GestureDetector(
                    onTap: _enterAsGuest,
                    child: GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text(
                          'Continue as Guest',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS CARD (reused from other screens – we keep a local copy or reference)
// ============================================================================
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 18.0,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.blur = 16.0,
    this.margin = EdgeInsets.zero,
    this.hasBorder = true,
  });

  final Widget child;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double blur;
  final EdgeInsetsGeometry margin;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              highlightColor: Colors.white.withOpacity(0.08),
              splashColor: Colors.white.withOpacity(0.12),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: hasBorder
                      ? Border.all(color: Colors.white.withOpacity(0.15), width: 0.8)
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}