import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/features/authentication/login/pages/login.dart';
import 'register_location.dart';
import '../../../gradient_scaffold.dart'; // gradient background

// ============================================================================
// PASSWORD STRENGTH ENUM
// ============================================================================
enum PasswordStrength { none, weak, medium, strong }

// ============================================================================
// REGISTER SCREEN
// ============================================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedRole;
  String? _selectedEmirate;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Location data (now required)
  double? _latitude;
  double? _longitude;
  String? _pickedAddress;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _roleError;
  String? _emirateError;
  String? _addressError;        // new: address required
  String? _generalError;

  double _passwordStrength = 0.0;
  PasswordStrength _strengthLevel = PasswordStrength.none;

  final List<String> _emirates = ['dubai', 'sharjah', 'ajman'];
  final List<String> _roles = ['user', 'tenant'];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    _selectedRole = 'user';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
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
    if (password.isEmpty) return {'score': 0.0, 'level': PasswordStrength.none};

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

  bool _validateFields() {
    bool isValid = true;

    // Name
    if (_nameController.text.trim().isEmpty) {
      _nameError = 'Full name is required';
      isValid = false;
    } else if (_nameController.text.trim().length < 3) {
      _nameError = 'Name must be at least 3 characters';
      isValid = false;
    } else {
      _nameError = null;
    }

    // Email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _emailError = 'Enter a valid email address';
      isValid = false;
    } else {
      _emailError = null;
    }

    // Phone
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (phone.length < 8) {
      _phoneError = 'Enter a valid phone number';
      isValid = false;
    } else {
      _phoneError = null;
    }

    // Password
    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
      isValid = false;
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _passwordError = 'Include at least 1 uppercase letter';
      isValid = false;
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      _passwordError = 'Include at least 1 lowercase letter';
      isValid = false;
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      _passwordError = 'Include at least 1 number';
      isValid = false;
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      _passwordError = 'Include at least 1 special character';
      isValid = false;
    } else {
      _passwordError = null;
    }

    // Role
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      _roleError = 'Please select user type';
      isValid = false;
    } else {
      _roleError = null;
    }

    // Emirate
    if (_selectedEmirate == null || _selectedEmirate!.isEmpty) {
      _emirateError = 'Please select your emirate';
      isValid = false;
    } else {
      _emirateError = null;
    }

    // Address (now required)
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _addressError = 'Please select your address using the GPS button';
      isValid = false;
    } else {
      _addressError = null;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _register() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _roleError = null;
      _emirateError = null;
      _addressError = null;
      _generalError = null;
    });

    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Api.registerUser(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole!,
        emirate: _selectedEmirate!,
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSuccessDialog();
      } else {
        setState(() {
          _generalError = response['message'] ?? 'Registration failed. Please try again.';
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

  void _showSuccessDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Registration Successful!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your account has been created.\nPlease login to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLocationPicker() async {
    if (_selectedEmirate == null) {
      _showSnackBar('Please select an emirate first');
      return;
    }
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterLocationScreen(selectedEmirate: _selectedEmirate!),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _pickedAddress = result['address'];
        if (_pickedAddress != null && _pickedAddress!.isNotEmpty) {
          _addressController.text = _pickedAddress!;
          // Clear any previous address error when picked
          if (_addressError != null) setState(() => _addressError = null);
        }
      });
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GLASS STYLED TEXT FIELD (identical to login screen)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? errorText,
    VoidCallback? onToggleVisibility,
    bool showVisibilityToggle = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
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
              color: hasError ? Colors.redAccent : Colors.white.withOpacity(0.18),
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: keyboardType,
            onChanged: onChanged,
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
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GLASS STYLED DROPDOWN (identical to login screen)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGlassDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String hintText,
    required void Function(String?) onChanged,
    String? errorText,
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
              color: hasError ? Colors.redAccent : Colors.white.withOpacity(0.18),
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hintText, style: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 13)),
              dropdownColor: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.55)),
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
        ],
      ],
    );
  }

  Color _getStrengthColor() {
    switch (_strengthLevel) {
      case PasswordStrength.weak: return Colors.redAccent;
      case PasswordStrength.medium: return Colors.orange;
      case PasswordStrength.strong: return Colors.green;
      default: return Colors.white.withOpacity(0.2);
    }
  }

  String _getStrengthText() {
    switch (_strengthLevel) {
      case PasswordStrength.weak: return 'Weak';
      case PasswordStrength.medium: return 'Medium';
      case PasswordStrength.strong: return 'Strong';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleItems = _roles.map((role) {
      return DropdownMenuItem<String>(
        value: role,
        child: Text(role[0].toUpperCase() + role.substring(1)),
      );
    }).toList();

    final emirateItems = _emirates.map((emirate) {
      return DropdownMenuItem<String>(
        value: emirate,
        child: Text(emirate[0].toUpperCase() + emirate.substring(1)),
      );
    }).toList();

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
                  const Text(
                    'FIXCO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xCCFFFFFF), fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 48),

                  // Full Name
                  _buildGlassTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                    errorText: _nameError,
                    onChanged: (_) => setState(() { if (_nameError != null) _nameError = null; }),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _buildGlassTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() { if (_emailError != null) _emailError = null; }),
                  ),
                  const SizedBox(height: 20),

                  // Phone
                  _buildGlassTextField(
                    controller: _phoneController,
                    hintText: 'Phone',
                    icon: Icons.phone_outlined,
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() { if (_phoneError != null) _phoneError = null; }),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  _buildGlassTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    showVisibilityToggle: true,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
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
                        Text(_getStrengthText(), style: TextStyle(color: _getStrengthColor(), fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ] else const SizedBox(height: 20),

                  // Role dropdown
                  _buildGlassDropdown(
                    value: _selectedRole,
                    items: roleItems,
                    hintText: 'Select User Type',
                    onChanged: (val) {
                      setState(() {
                        _selectedRole = val;
                        if (_roleError != null) _roleError = null;
                      });
                    },
                    errorText: _roleError,
                  ),
                  const SizedBox(height: 20),

                  // Emirate dropdown
                  _buildGlassDropdown(
                    value: _selectedEmirate,
                    items: emirateItems,
                    hintText: 'Select Emirate',
                    onChanged: (val) {
                      setState(() {
                        _selectedEmirate = val;
                        if (_emirateError != null) _emirateError = null;
                      });
                    },
                    errorText: _emirateError,
                  ),
                  const SizedBox(height: 20),

                  // Address field + location button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGlassTextField(
                          controller: _addressController,
                          hintText: 'Address (required)',
                          icon: Icons.location_on_outlined,
                          errorText: _addressError,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _openLocationPicker,
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                          ),
                          child: Icon(Icons.gps_fixed, color: Colors.white.withOpacity(0.7), size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // General error
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
                          Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_generalError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Register button (glass style)
                  GestureDetector(
                    onTap: _isLoading ? null : _register,
                    child: GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                          else ...[
                            const Icon(Icons.person_add_rounded, color: Colors.white70, size: 18),
                            const SizedBox(width: 10),
                            const Text(
                              'Register',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
// GLASS CARD (reused from other screens)
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