import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/features/profile/profile.dart'; // barrel exports: ProfileMenuItem, LogoutButton, PrivacyPolicyPage, TermsPage, HelpPage

// ---------------------------------------------------------------------
// Inline ProfileModel – avoids missing import errors
// ---------------------------------------------------------------------
class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] ?? 'No name',
      email: map['email'] ?? 'No email',
      phone: map['phone'] ?? 'No phone',
      avatarUrl: map['avatar_url'],
    );
  }
}

// ---------------------------------------------------------------------
// Main ProfilePage widget
// ---------------------------------------------------------------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  String? _error;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    if (UserSession.isLoggedIn()) {
      _fetchProfile();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (!UserSession.isLoggedIn()) {
      setState(() {
        _error = 'Not logged in';
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await Api.getUserProfile(UserSession.userId!);
      if (!mounted) return;

      if (result['status'] == 'success') {
        setState(() {
          _profile = ProfileModel.fromMap(result['user'] as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] as String? ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // -----------------------------------------------------------------
  // LOGOUT HANDLER – uses UserSession.logout() (not .clear)
  // -----------------------------------------------------------------
  Future<void> _handleLogout() async {
    await UserSession.logout();                // ✅ correct method
    if (mounted) {
      // Navigate to the login screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final isLoggedIn = UserSession.isLoggedIn();

    if (!isLoggedIn) {
      return _buildGuestBody();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(error: _error!, onRetry: _fetchProfile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileInfoCard(profile: _profile!),
        const SizedBox(height: 24),
        _buildMenuItems(),
        const SizedBox(height: 16),
        LogoutButton(onPressed: _handleLogout),
      ],
    );
  }

  Widget _buildGuestBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.lock_outline, size: 32, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Guest User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to access your profile',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Login / Sign Up'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildMenuItems(),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.assignment_outlined,
          title: 'Privacy Policy',
          onTap: () => _navigateToPage(const PrivacyPolicyPage()),
        ),
        ProfileMenuItem(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          onTap: () => _navigateToPage(const TermsPage()),
        ),
        ProfileMenuItem(
          icon: Icons.help_outline,
          title: 'Help',
          onTap: () => _navigateToPage(const HelpPage()),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Helper widgets (profile info card, error view)
// ---------------------------------------------------------------------
class _ProfileInfoCard extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange.shade100,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              profile.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 32),
            _InfoRow(icon: Icons.phone, label: 'Phone', value: profile.phone),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.email, label: 'Email', value: profile.email),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}