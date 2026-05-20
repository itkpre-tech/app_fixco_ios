// import 'package:flutter/material.dart';
// import 'package:fixco/features/profile/shared/profile_constants.dart';
//
// class LogoutButton extends StatelessWidget {
//   const LogoutButton({super.key, required this.onPressed});
//   final VoidCallback onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onPressed: onPressed,
//         child: const Text(
//           ProfileConstants.logoutButton,
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }