import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import '../models/profile_model.dart';
import 'profile_edit_profile.dart';
import 'profile_saved_addresses.dart';
import 'profile_payment_methods.dart';
import 'profile_invoices.dart';
import 'profile_privacy_policy.dart';
import 'profile_help.dart';
import 'profile_report_issue.dart';
import '../../gradient_scaffold.dart';

// ============================================================================
// GLASS CARD – identical to about.dart (no scale animation, just ripple)
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
// ARROW BUTTON (circular blurred, matches about.dart)
// ============================================================================
class ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SVG ICON (copied from about.dart – pure white stroke icons)
// ============================================================================
class _SvgIcon extends StatelessWidget {
  final String svgPath;
  final double size;
  const _SvgIcon(this.svgPath, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SvgPainter(svgPath, size),
      ),
    );
  }
}

class _SvgPainter extends CustomPainter {
  final String id;
  final double size;
  const _SvgPainter(this.id, this.size);

  @override
  void paint(Canvas canvas, Size sz) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = sz.width / 24;

    switch (id) {
      case 'person':
        canvas.drawCircle(Offset(12 * s, 8 * s), 4 * s, paint);
        final body = Path()
          ..moveTo(4 * s, 22 * s)
          ..cubicTo(4 * s, 18 * s, 7.6 * s, 15 * s, 12 * s, 15 * s)
          ..cubicTo(16.4 * s, 15 * s, 20 * s, 18 * s, 20 * s, 22 * s);
        canvas.drawPath(body, paint);
        break;

      case 'location':
        final pin = Path()
          ..moveTo(12 * s, 22 * s)
          ..cubicTo(12 * s, 22 * s, 5 * s, 15 * s, 5 * s, 10 * s)
          ..cubicTo(5 * s, 6.1 * s, 8.1 * s, 3 * s, 12 * s, 3 * s)
          ..cubicTo(15.9 * s, 3 * s, 19 * s, 6.1 * s, 19 * s, 10 * s)
          ..cubicTo(19 * s, 15 * s, 12 * s, 22 * s, 12 * s, 22 * s)
          ..close();
        canvas.drawPath(pin, paint);
        canvas.drawCircle(Offset(12 * s, 10 * s), 2.5 * s, paint);
        break;

      case 'credit_card':
        final card = Path()
          ..moveTo(4 * s, 6 * s)
          ..lineTo(20 * s, 6 * s)
          ..lineTo(20 * s, 18 * s)
          ..lineTo(4 * s, 18 * s)
          ..close();
        canvas.drawPath(card, paint);
        canvas.drawLine(Offset(4 * s, 10 * s), Offset(20 * s, 10 * s), paint);
        canvas.drawLine(Offset(4 * s, 14 * s), Offset(12 * s, 14 * s), paint);
        break;

      case 'privacy':
        final shield = Path()
          ..moveTo(12 * s, 2 * s)
          ..lineTo(20 * s, 6 * s)
          ..lineTo(20 * s, 12 * s)
          ..cubicTo(20 * s, 16.5 * s, 16.5 * s, 20.5 * s, 12 * s, 22 * s)
          ..cubicTo(7.5 * s, 20.5 * s, 4 * s, 16.5 * s, 4 * s, 12 * s)
          ..lineTo(4 * s, 6 * s)
          ..close();
        canvas.drawPath(shield, paint);
        final check = Path()
          ..moveTo(8.5 * s, 12 * s)
          ..lineTo(11 * s, 14.5 * s)
          ..lineTo(15.5 * s, 9.5 * s);
        canvas.drawPath(check, paint);
        break;

      case 'help':
        canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, paint);
        final q = Path()
          ..moveTo(12 * s, 16 * s)
          ..lineTo(12 * s, 16.5 * s);
        canvas.drawPath(q, paint);
        canvas.drawArc(
            Rect.fromCircle(center: Offset(12 * s, 13 * s), radius: 3 * s),
            3.14 * 0.8, 3.14 * 1.4, false, paint);
        break;

      case 'bug':
        final bug = Path()
          ..moveTo(12 * s, 5 * s)
          ..cubicTo(9 * s, 5 * s, 8 * s, 8 * s, 8 * s, 10 * s)
          ..cubicTo(5 * s, 10 * s, 4 * s, 13 * s, 6 * s, 15 * s)
          ..cubicTo(6 * s, 17 * s, 8 * s, 19 * s, 12 * s, 19 * s)
          ..cubicTo(16 * s, 19 * s, 18 * s, 17 * s, 18 * s, 15 * s)
          ..cubicTo(20 * s, 13 * s, 19 * s, 10 * s, 16 * s, 10 * s)
          ..cubicTo(16 * s, 8 * s, 15 * s, 5 * s, 12 * s, 5 * s)
          ..close();
        canvas.drawPath(bug, paint);
        canvas.drawLine(Offset(8 * s, 10 * s), Offset(6 * s, 8 * s), paint);
        canvas.drawLine(Offset(16 * s, 10 * s), Offset(18 * s, 8 * s), paint);
        break;

      case 'verified':
        final v = Path()
          ..moveTo(12 * s, 2 * s)
          ..lineTo(20 * s, 6 * s)
          ..lineTo(20 * s, 12 * s)
          ..cubicTo(20 * s, 16.5 * s, 16.5 * s, 20.5 * s, 12 * s, 22 * s)
          ..cubicTo(7.5 * s, 20.5 * s, 4 * s, 16.5 * s, 4 * s, 12 * s)
          ..lineTo(4 * s, 6 * s)
          ..close();
        canvas.drawPath(v, paint);
        final tick = Path()
          ..moveTo(8.5 * s, 12 * s)
          ..lineTo(11 * s, 14.5 * s)
          ..lineTo(15.5 * s, 9.5 * s);
        canvas.drawPath(tick, paint);
        break;

      case 'language':
        final globe = Path()
          ..moveTo(12 * s, 2 * s)
          ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
          ..cubicTo(2 * s, 17.5 * s, 6.5 * s, 22 * s, 12 * s, 22 * s)
          ..cubicTo(17.5 * s, 22 * s, 22 * s, 17.5 * s, 22 * s, 12 * s)
          ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
          ..close();
        canvas.drawPath(globe, paint);
        canvas.drawLine(Offset(2 * s, 12 * s), Offset(22 * s, 12 * s), paint);
        canvas.drawLine(Offset(12 * s, 2 * s), Offset(12 * s, 22 * s), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
}

// ============================================================================
// PROFILE PAGE – same scroll/refresh behavior as contact.dart & home.dart
// ============================================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Only used for the very first load to decide whether to show content at all.
  // During pull-to-refresh we never show any loading indicator – data just
  // updates silently, exactly like contact.dart (_refresh).
  bool _isLoading = true;
  String? _initialLoadError;
  ProfileModel? _profile;

  bool get _isLoggedIn => UserSession.isLoggedIn();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isLoggedIn && UserSession.userId != null) {
      await _fetchProfile(isInitialLoad: true);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fetch profile data.
  /// [isInitialLoad] = true  → show skeleton until data arrives (first open).
  /// [isInitialLoad] = false → silent background refresh (pull-to-refresh),
  ///                           no loading state changes, no spinner, no text.
  Future<void> _fetchProfile({bool isInitialLoad = false}) async {
    if (UserSession.userId == null) {
      if (isInitialLoad && mounted) setState(() => _isLoading = false);
      return;
    }

    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _initialLoadError = null;
      });
    }

    try {
      final result = await Api.getUserProfile(UserSession.userId!);
      if (!mounted) return;

      if (result['status'] == 'success' && result['user'] != null) {
        // Always update the profile data silently – no loading flag during refresh
        setState(() {
          _profile = ProfileModel.fromMap(result['user'] as Map<String, dynamic>);
          if (isInitialLoad) _isLoading = false;
        });
      } else {
        final errorMsg = result['message'] ?? 'Failed to load profile';
        if (isInitialLoad) {
          setState(() {
            _initialLoadError = errorMsg;
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (isInitialLoad) {
        setState(() {
          _initialLoadError = e.toString();
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network error'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  /// Pull-to-refresh handler – mirrors contact.dart's `_refresh()`:
  /// a brief delay then silently update data, no loading UI whatsoever.
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_isLoggedIn && mounted) {
      await _fetchProfile(isInitialLoad: false);
    }
    if (mounted) setState(() {});
  }

  Future<void> _changeLanguage(String lang) async {
    final locale = lang == 'Arabic' ? const Locale('ar') : const Locale('en');
    await context.setLocale(locale);
  }

  Future<void> _handleLogout() async {
    await UserSession.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 30;

    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        // Matches contact.dart / home.dart styling exactly
        color: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.10),
        child: CustomScrollView(
          // AlwaysScrollableScrollPhysics keeps the page pinned (no bounce/
          // overscroll shift) and enables pull-to-refresh at the top –
          // identical to contact.dart and home.dart.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTitleBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
              sliver: SliverToBoxAdapter(child: _buildBody()),
            ),
          ],
        ),
      ),
    );
  }

  // Title bar – exactly like contact.dart
  Widget _buildTitleBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(
          'profile_title'.tr(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Only show the loading placeholder on the very first open
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
        ),
      );
    }

    // Error only shown on initial load failure
    if (_initialLoadError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(_initialLoadError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _fetchProfile(isInitialLoad: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    // Normal content – always visible, refreshes happen silently in background
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoggedIn && _profile != null) ...[
          _buildProfileCard(),
          const SizedBox(height: 24),
        ] else if (!_isLoggedIn) ...[
          _buildGuestCard(),
          const SizedBox(height: 24),
        ],

        // Logged-in specific menu items
        if (_isLoggedIn) ...[
          _buildMenuItem(
            svgIcon: 'person',
            title: 'edit_profile'.tr(),
            onTap: () => _navigateToPage(const ProfileEditProfile()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            svgIcon: 'location',
            title: 'saved_addresses'.tr(),
            onTap: () => _navigateToPage(const ProfileSavedAddresses()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            svgIcon: 'credit_card',
            title: 'payment_methods'.tr(),
            onTap: () => _navigateToPage(const ProfilePaymentMethods()),
          ),
          const SizedBox(height: 12),
        ],

        // Common menu items
        _buildLanguageTile(),
        const SizedBox(height: 12),
        _buildMenuItem(
          svgIcon: 'privacy',
          title: 'privacy_policy'.tr(),
          onTap: () => _navigateToPage(ProfilePrivacyPolicy(isDark: false)),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          svgIcon: 'help',
          title: 'help'.tr(),
          onTap: () => _navigateToPage(ProfileHelp(isDark: false)),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          svgIcon: 'bug',
          title: 'report_issue'.tr(),
          onTap: () => _navigateToPage(const ProfileReportIssue()),
        ),
        const SizedBox(height: 12),
        _buildAppVersionTile(),
        const SizedBox(height: 12),

        // Logout button
        if (_isLoggedIn) _buildLogoutButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileCard() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: const _SvgIcon('person', size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            _profile?.fullName ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: const _SvgIcon('person', size: 40),
          ),
          const SizedBox(height: 18),
          Text('guest_user'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 10),
          Text('guest_description'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.6, fontSize: 14, color: Colors.white.withOpacity(0.70))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('login_signup'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String svgIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          _SvgIcon(svgIcon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          ArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    String language = context.locale.languageCode == 'ar' ? 'Arabic' : 'English';
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const _SvgIcon('language', size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'language'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: language,
              dropdownColor: const Color(0xFF1E1E1E),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7)),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              items: [
                DropdownMenuItem(value: 'English', child: Text('english'.tr())),
                DropdownMenuItem(value: 'Arabic', child: Text('arabic'.tr())),
              ],
              onChanged: (v) {
                if (v != null) _changeLanguage(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersionTile() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const _SvgIcon('verified', size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'app_version'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            '1.6',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: _handleLogout,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Text(
            'logout'.tr(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}