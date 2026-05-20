import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import '../../gradient_scaffold.dart';

// ============================================================================
// GLASS CARD – identical to login/register screens
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

// ============================================================================
// FORGOT PASSWORD SCREEN – glass design
// ============================================================================
enum ForgotPasswordState { idle, loading, success, error }

class ForgotPasswordScreen extends StatefulWidget {
  final String? prefillEmail;

  const ForgotPasswordScreen({super.key, this.prefillEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  ForgotPasswordState _state = ForgotPasswordState.idle;
  String? _responseMessage;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null) {
      _emailController.text = widget.prefillEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();

    final email = _emailController.text.trim();

    // Validate
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    setState(() {
      _emailError = null;
      _state = ForgotPasswordState.loading;
      _responseMessage = null;
    });

    try {
      final response = await Api.forgotPassword(email);
      if (!mounted) return;

      final isSuccess = response['status'] == 'success';
      setState(() {
        _state = isSuccess ? ForgotPasswordState.success : ForgotPasswordState.error;
        _responseMessage = response['message'] ??
            (isSuccess
                ? 'Reset link sent! Check your inbox.'
                : 'Something went wrong. Please try again.');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = ForgotPasswordState.error;
        _responseMessage = 'Network error. Please check your connection.';
      });
    }
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _state == ForgotPasswordState.success;
    final isLoading = _state == ForgotPasswordState.loading;
    final hasError = _state == ForgotPasswordState.error;

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: isSuccess ? _buildSuccessView() : _buildFormView(isLoading, hasError),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUCCESS VIEW (glass card style)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withOpacity(0.4), width: 1.5),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: Colors.green, size: 38),
        ),
        const SizedBox(height: 28),

        const Text(
          'Check Your Inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          _responseMessage ??
              'If your email is registered, you will receive a password reset link shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.65),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 40),

        // Back to Login button (glass)
        GlassCard(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(vertical: 14),
          onTap: _goBack,
          child: const Center(
            child: Text(
              'Back to Login',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Resend option
        TextButton(
          onPressed: () {
            setState(() {
              _state = ForgotPasswordState.idle;
              _responseMessage = null;
            });
          },
          child: Text(
            'Didn\'t receive it? Try again',
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORM VIEW (glass card + glass text fields)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormView(bool isLoading, bool hasError) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lock icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: const Icon(Icons.lock_reset_rounded, color: Colors.white70, size: 34),
          ),
        ),
        const SizedBox(height: 28),

        const Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          'Enter your registered email address and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.55),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // Email input (glass style)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _emailError != null
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.18),
                  width: _emailError != null ? 1.5 : 1.0,
                ),
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => isLoading ? null : _submit(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 13),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: _emailError != null
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.55),
                    size: 19,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                ),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
            ),
            if (_emailError != null) ...[
              const SizedBox(height: 6),
              Text(_emailError!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // API error banner
        if (hasError && _responseMessage != null) ...[
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
                    _responseMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Submit button (glass)
        GlassCard(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(vertical: 14),
          onTap: isLoading ? null : _submit,
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            )
                : const Text(
              'Send Reset Link',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Back to login link
        Center(
          child: GestureDetector(
            onTap: _goBack,
            child: Text.rich(
              TextSpan(
                text: 'Remember your password? ',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                children: const [
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}