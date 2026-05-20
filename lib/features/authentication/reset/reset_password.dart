import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';

// ============================================================================
// WAVE PAINTERS (same as login/register)
// ============================================================================

class _WaveHeaderPainter extends CustomPainter {
  const _WaveHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6A6A6A).withOpacity(0.85),
          const Color(0xFF4A4A4A).withOpacity(0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final wavePath = Path()
      ..moveTo(0, size.height * 0.70)
      ..cubicTo(
        size.width * 0.2, size.height * 0.50,
        size.width * 0.4, size.height * 0.80,
        size.width * 0.6, size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.8, size.height * 0.40,
        size.width * 0.95, size.height * 0.70,
        size.width, size.height * 0.55,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FogWavePainter extends CustomPainter {
  const _FogWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 1.2),
        radius: 1.2,
        colors: [
          const Color(0xFF2A2A2A).withOpacity(0.9),
          const Color(0xFF1A1A1A).withOpacity(0.7),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final wavePath = Path()
      ..moveTo(0, size.height * 0.48)
      ..cubicTo(
        size.width * 0.25, size.height * 0.63,
        size.width * 0.5, size.height * 0.46,
        size.width * 0.75, size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.9, size.height * 0.66,
        size.width * 0.98, size.height * 0.53,
        size.width, size.height * 0.56,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// RESET PASSWORD SCREEN
// ============================================================================

enum ResetState { idle, loading, success, error }

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  ResetState _state = ResetState.idle;
  String? _errorMessage;
  String? _successMessage;

  // Password strength
  double _passwordStrength = 0.0;
  PasswordStrength _strengthLevel = PasswordStrength.none;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
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

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include at least 1 lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least 1 number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Include at least 1 special character';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    HapticFeedback.lightImpact();

    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Validate
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      setState(() => _errorMessage = passwordError);
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = "Passwords don't match");
      return;
    }

    setState(() {
      _state = ResetState.loading;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await Api.resetPassword(
        token: widget.token,
        newPassword: password,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        setState(() {
          _state = ResetState.success;
          _successMessage = response['message'] ??
              'Password reset successfully. Please login with your new password.';
        });
      } else {
        setState(() {
          _state = ResetState.error;
          _errorMessage = response['message'] ?? 'Invalid or expired link.';
        });
      }
    } catch (e) {
      setState(() {
        _state = ResetState.error;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  void _goToLogin() {
    HapticFeedback.lightImpact();
    // Pop all the way back to login screen (assuming login is the first screen)
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Or navigate to login screen directly:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isSuccess = _state == ResetState.success;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(color: Colors.black),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.5,
            child: const CustomPaint(painter: _WaveHeaderPainter()),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.8,
            child: const CustomPaint(painter: _FogWavePainter()),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: isSuccess ? _buildSuccessView() : _buildFormView(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withOpacity(0.4), width: 1.5),
          ),
          child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 42),
        ),
        const SizedBox(height: 28),
        const Text(
          'Password Reset!',
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
          _successMessage ?? 'Your password has been changed successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.65),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _goToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Go to Login',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    final isLoading = _state == ResetState.loading;
    final hasError = _state == ResetState.error;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create New Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your new password must be different from previously used passwords.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.55),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // New Password
        _buildPasswordField(
          controller: _passwordController,
          hint: 'New Password',
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 8),

        // Password strength
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
              Text(_getStrengthText(), style: TextStyle(color: _getStrengthColor(), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Confirm Password
        _buildPasswordField(
          controller: _confirmController,
          hint: 'Confirm Password',
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 16),

        // Error message
        if (hasError && _errorMessage != null)
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
                Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
                : const Text(
              'Reset Password',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Back to login link
        Center(
          child: GestureDetector(
            onTap: _goToLogin,
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 13),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.white.withOpacity(0.55),
            size: 19,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.white.withOpacity(0.55),
              size: 18,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}

enum PasswordStrength { none, weak, medium, strong }