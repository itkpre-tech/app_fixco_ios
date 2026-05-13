// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fixco/services/api.dart';
// import 'package:fixco/features/projects/pages/id_projects.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Brand tokens
// // ─────────────────────────────────────────────────────────────────────────────
// const Color _primary      = Color(0xFFE65100);
// const Color _primaryLight = Color(0xFFFF8A50);
// const Color _accent       = Color(0xFFFF6D2D);
// const Color _bgWhite      = Color(0xFFFFFFFF);
// const Color _surface      = Color(0xFFF5F5F5);
// const Color _surfaceHigh  = Color(0xFFEEEEEE);
// const Color _textDark     = Color(0xFF1A1A1A);
// const Color _textMid      = Color(0xFF666666);
// const Color _textLight    = Color(0xFFAAAAAA);
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Image helper
// // ─────────────────────────────────────────────────────────────────────────────
// ImageProvider _resolveImage(String src) {
//   if (src.startsWith('http://') || src.startsWith('https://')) {
//     return NetworkImage(src);
//   } else if (src.startsWith('data:image')) {
//     try {
//       return MemoryImage(base64Decode(src.split(',').last));
//     } catch (_) {
//       return const NetworkImage('');
//     }
//   }
//   return NetworkImage('http://admin.medco-contracting.com$src');
// }
//
// class _CachedImage extends StatelessWidget {
//   final String? src;
//   final BoxFit fit;
//   final Widget fallback;
//   const _CachedImage(
//       {required this.src, this.fit = BoxFit.cover, required this.fallback});
//
//   @override
//   Widget build(BuildContext context) {
//     if (src == null || src!.isEmpty) return fallback;
//     return Image(
//       image: _resolveImage(src!),
//       fit: fit,
//       gaplessPlayback: true,
//       errorBuilder: (_, __, ___) => fallback,
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Model
// // ─────────────────────────────────────────────────────────────────────────────
// class _Project {
//   final String id, title, coverImage, description, location, status;
//   final List<dynamic> gallery;
//
//   _Project({
//     required this.id,
//     required this.title,
//     required this.coverImage,
//     this.description = '',
//     this.location = '',
//     this.status = '',
//     this.gallery = const [],
//   });
//
//   factory _Project.fromJson(Map<String, dynamic> j) => _Project(
//     id: j['id']?.toString() ?? '',
//     title: j['title']?.toString() ?? '',
//     coverImage: j['cover_image']?.toString() ?? '',
//     description: j['description']?.toString() ?? '',
//     location: j['location']?.toString() ?? '',
//     status: j['status']?.toString() ?? '',
//     gallery: j['gallery'] ?? [],
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // AllProjectsPage
// // ─────────────────────────────────────────────────────────────────────────────
// class AllProjectsPage extends StatefulWidget {
//   const AllProjectsPage({super.key});
//
//   @override
//   State<AllProjectsPage> createState() => _AllProjectsPageState();
// }
//
// class _AllProjectsPageState extends State<AllProjectsPage>
//     with SingleTickerProviderStateMixin {
//   List<_Project> _projects = [];
//   bool _loading = true;
//   String? _error;
//
//   late final AnimationController _fadeCtrl = AnimationController(
//       vsync: this, duration: const Duration(milliseconds: 700))
//     ..forward();
//   late final Animation<double> _fadeAnim =
//   CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProjects();
//   }
//
//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchProjects() async {
//     setState(() {
//       _loading = true;
//       _error   = null;
//     });
//     try {
//       final data = await Api.getProjects();
//       if (!mounted) return;
//       setState(() {
//         _projects = data.map((j) => _Project.fromJson(j)).toList();
//         _loading  = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error   = e.toString();
//         _loading = false;
//       });
//     }
//   }
//
//   void _openProject(String id) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => ProjectDetailPage(projectId: id)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgWhite,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // ── App Bar ──────────────────────────────────────────────────────
//           SliverAppBar(
//             backgroundColor: _bgWhite,
//             surfaceTintColor: Colors.transparent,
//             elevation: 0,
//             pinned: true,
//             expandedHeight: 130,
//             leading: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 margin: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _surface,
//                   border: Border.all(
//                       color: Colors.grey.withValues(alpha: 0.18), width: 1),
//                 ),
//                 child:
//                 const Icon(Icons.arrow_back_rounded, color: _textDark, size: 20),
//               ),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               titlePadding:
//               const EdgeInsets.fromLTRB(20, 0, 20, 16),
//               title: const Text(
//                 'All Projects',
//                 style: TextStyle(
//                   color: _textDark,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               background: Container(
//                 alignment: Alignment.bottomLeft,
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 52),
//                 child: Text(
//                   'Explore our completed work',
//                   style: TextStyle(color: _textLight, fontSize: 13),
//                 ),
//               ),
//             ),
//           ),
//
//           // ── Content ───────────────────────────────────────────────────────
//           if (_loading)
//             const SliverFillRemaining(
//               child: Center(
//                 child: CircularProgressIndicator(
//                     color: _primary, strokeWidth: 2.5),
//               ),
//             )
//           else if (_error != null)
//             SliverFillRemaining(child: _buildError())
//           else if (_projects.isEmpty)
//               SliverFillRemaining(child: _buildEmpty())
//             else
//               SliverFadeTransition(
//                 opacity: _fadeAnim,
//                 sliver: SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
//                   sliver: SliverGrid(
//                     gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 14,
//                       mainAxisSpacing: 14,
//                       childAspectRatio: 0.78,
//                     ),
//                     delegate: SliverChildBuilderDelegate(
//                           (_, i) => _ProjectGridCard(
//                         project: _projects[i],
//                         onView: () => _openProject(_projects[i].id),
//                       ),
//                       childCount: _projects.length,
//                     ),
//                   ),
//                 ),
//               ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildError() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 68,
//               height: 68,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red.withValues(alpha: 0.06),
//                 border: Border.all(
//                     color: Colors.red.withValues(alpha: 0.18), width: 1.5),
//               ),
//               child: Icon(Icons.wifi_off_rounded,
//                   color: Colors.redAccent.withValues(alpha: 0.65), size: 32),
//             ),
//             const SizedBox(height: 16),
//             const Text('Failed to load projects',
//                 style: TextStyle(
//                     color: _textMid,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             Text(_error ?? '',
//                 style: const TextStyle(color: _textLight, fontSize: 12),
//                 textAlign: TextAlign.center),
//             const SizedBox(height: 24),
//             GestureDetector(
//               onTap: _fetchProjects,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 32, vertical: 13),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                       colors: [_primary, _accent]),
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                         color: _primary.withValues(alpha: 0.28),
//                         blurRadius: 14,
//                         offset: const Offset(0, 5))
//                   ],
//                 ),
//                 child: const Text('Try Again',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: _primary.withValues(alpha: 0.06),
//               border: Border.all(
//                   color: _primary.withValues(alpha: 0.18), width: 1.5),
//             ),
//             child: Icon(Icons.folder_off_rounded,
//                 color: _primary.withValues(alpha: 0.45), size: 38),
//           ),
//           const SizedBox(height: 18),
//           const Text('No Projects Found',
//               style: TextStyle(
//                   color: _textMid,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700)),
//           const SizedBox(height: 8),
//           const Text('Projects will appear here once added.',
//               style: TextStyle(color: _textLight, fontSize: 13)),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Project Grid Card (2-column layout with View button)
// // ─────────────────────────────────────────────────────────────────────────────
// class _ProjectGridCard extends StatelessWidget {
//   final _Project project;
//   final VoidCallback onView;
//   const _ProjectGridCard(
//       {required this.project, required this.onView});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.10),
//               blurRadius: 14,
//               offset: const Offset(0, 5))
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(18),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Cover image
//             _CachedImage(
//               src: project.coverImage,
//               fallback: Container(
//                 color: _surfaceHigh,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.image_rounded,
//                         color: _textLight, size: 40),
//                     const SizedBox(height: 8),
//                     Text(project.title,
//                         style: const TextStyle(
//                             color: _textLight, fontSize: 11),
//                         textAlign: TextAlign.center,
//                         maxLines: 2),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Gradient overlay
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withValues(alpha: 0.85),
//                   ],
//                   stops: const [0.30, 1.0],
//                 ),
//               ),
//             ),
//
//             // Left accent bar
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: Container(
//                 width: 3,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [_primary, _accent],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Status badge (top right)
//             if (project.status.isNotEmpty)
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: _primary.withValues(alpha: 0.85),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     project.status,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 8,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.5),
//                   ),
//                 ),
//               ),
//
//             // Title + View button at bottom
//             Positioned(
//               left: 10,
//               right: 10,
//               bottom: 12,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(project.title,
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           height: 1.3),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis),
//                   if (project.location.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Row(children: [
//                       Icon(Icons.location_on_rounded,
//                           color: _primaryLight.withValues(alpha: 0.8),
//                           size: 10),
//                       const SizedBox(width: 3),
//                       Expanded(
//                         child: Text(project.location,
//                             style: TextStyle(
//                                 color: Colors.white
//                                     .withValues(alpha: 0.65),
//                                 fontSize: 9),
//                             overflow: TextOverflow.ellipsis),
//                       ),
//                     ]),
//                   ],
//                   const SizedBox(height: 10),
//                   GestureDetector(
//                     onTap: onView,
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                             colors: [_primary, _accent]),
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: [
//                           BoxShadow(
//                               color: _primary.withValues(alpha: 0.35),
//                               blurRadius: 8,
//                               offset: const Offset(0, 3))
//                         ],
//                       ),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.visibility_rounded,
//                               color: Colors.white, size: 13),
//                           SizedBox(width: 5),
//                           Text('View Project',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }