// import 'package:flutter/material.dart';
// import 'package:fixco/services/api.dart';
// import 'package:fixco/services/user_session.dart';
// import '../models/profile_model.dart';
// import '../cards/profile_info_card.dart';
//
// /// Displays detailed profile information for the currently logged-in user.
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   bool _isLoading = true;
//   String? _error;
//   ProfileModel? _profile;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfile();
//   }
//
//   Future<void> _fetchProfile() async {
//     if (!UserSession.isLoggedIn()) {
//       if (!mounted) return;
//       setState(() {
//         _error = 'Not logged in';
//         _isLoading = false;
//       });
//       return;
//     }
//
//     try {
//       final result = await Api.getUserProfile(UserSession.userId!);
//       if (!mounted) return;
//
//       if (result['status'] == 'success') {
//         setState(() {
//           _profile = ProfileModel.fromMap(result['user'] as Map<String, dynamic>);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = result['message'] as String? ?? 'Failed to load profile';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: _buildBody(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_isLoading) return const _LoadingView();
//     if (_error != null) return _ErrorView(error: _error!, onRetry: _fetchProfile);
//     return ProfileInfoCard(profile: _profile!);
//   }
// }
//
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       heightFactor: 5,
//       child: CircularProgressIndicator(),
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   const _ErrorView({required this.error, required this.onRetry});
//
//   final String error;
//   final VoidCallback onRetry;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       heightFactor: 5,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             error,
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onRetry,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }