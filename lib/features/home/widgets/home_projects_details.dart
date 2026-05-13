import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand tokens
// ─────────────────────────────────────────────────────────────────────────────
const Color _primary      = Color(0xFFE65100);
const Color _primaryLight = Color(0xFFFF8A50);
const Color _accent       = Color(0xFFFF6D2D);
const Color _bgWhite      = Color(0xFFFFFFFF);
const Color _surface      = Color(0xFFF5F5F5);
const Color _surfaceHigh  = Color(0xFFEEEEEE);
const Color _textDark     = Color(0xFF1A1A1A);
const Color _textMid      = Color(0xFF666666);
const Color _textLight    = Color(0xFFAAAAAA);

// ─────────────────────────────────────────────────────────────────────────────
// Image helper
// ─────────────────────────────────────────────────────────────────────────────
ImageProvider _resolveImage(String src) {
  if (src.startsWith('http://') || src.startsWith('https://')) {
    return NetworkImage(src);
  } else if (src.startsWith('data:image')) {
    try {
      return MemoryImage(base64Decode(src.split(',').last));
    } catch (_) {
      return const NetworkImage('');
    }
  }
  return NetworkImage('http://admin.medco-contracting.com$src');
}

class _NetImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Widget fallback;
  const _NetImage({
    required this.src,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) return fallback;
    return Image(
      image: _resolveImage(src!),
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full Project Model
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectDetail {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String location;
  final String status;
  final String client;
  final String startDate;
  final String endDate;
  final String category;
  final List<_GalleryImage> gallery;

  _ProjectDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    this.location = '',
    this.status = '',
    this.client = '',
    this.startDate = '',
    this.endDate = '',
    this.category = '',
    this.gallery = const [],
  });

  factory _ProjectDetail.fromJson(Map<String, dynamic> j) {
    final rawGallery = j['gallery'] as List<dynamic>? ?? [];
    return _ProjectDetail(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      coverImage: j['cover_image']?.toString() ?? '',
      location: j['location']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      client: j['client']?.toString() ?? '',
      startDate: j['start_date']?.toString() ?? '',
      endDate: j['end_date']?.toString() ?? '',
      category: j['category']?.toString() ?? '',
      gallery: rawGallery
          .map((g) => _GalleryImage.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}

class _GalleryImage {
  final String id, imagePath;
  _GalleryImage({required this.id, required this.imagePath});
  factory _GalleryImage.fromJson(Map<String, dynamic> j) => _GalleryImage(
    id: j['id']?.toString() ?? '',
    imagePath: j['image_path']?.toString() ?? '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProjectDetailPage
// ─────────────────────────────────────────────────────────────────────────────
class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  _ProjectDetail? _project;
  bool _loading = true;
  String? _error;

  int _selectedGalleryIndex = 0;
  final PageController _galleryCtrl = PageController();

  late final AnimationController _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();
  late final Animation<double> _fadeAnim =
  CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _fetchProject();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _galleryCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProject() async {
    setState(() {
      _loading = true;
      _error   = null;
    });
    try {
      // Re-use the getProjects API and find by id
      // If your API supports single project fetch, replace this with:
      // final data = await Api.getProjectById(widget.projectId);
      final allData = await Api.getProjects();
      if (!mounted) return;
      final match = allData.firstWhere(
            (j) => j['id']?.toString() == widget.projectId,
        orElse: () => <String, dynamic>{},
      );
      if (match.isEmpty) throw Exception('Project not found');
      setState(() {
        _project = _ProjectDetail.fromJson(match as Map<String, dynamic>);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(
              color: _primary, strokeWidth: 2.5))
          : _error != null
          ? _buildError()
          : _buildContent(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.06),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.18), width: 1.5),
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent.withValues(alpha: 0.65), size: 34),
            ),
            const SizedBox(height: 18),
            const Text('Failed to load project',
                style: TextStyle(
                    color: _textMid,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error ?? '',
                style: const TextStyle(color: _textLight, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.25)),
                    ),
                    child: const Text('Go Back',
                        style: TextStyle(
                            color: _textMid,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _fetchProject,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_primary, _accent]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: _primary.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Text('Retry',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN CONTENT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final p = _project!;
    final allImages = [
      if (p.coverImage.isNotEmpty) p.coverImage,
      ...p.gallery.map((g) => g.imagePath),
    ];

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Image Sliver App Bar ──────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 300,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.40),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: allImages.isEmpty
                  ? Container(
                color: _surfaceHigh,
                child: const Icon(Icons.image_rounded,
                    color: _textLight, size: 60),
              )
                  : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _galleryCtrl,
                    itemCount: allImages.length,
                    onPageChanged: (i) =>
                        setState(() => _selectedGalleryIndex = i),
                    itemBuilder: (_, i) => _NetImage(
                      src: allImages[i],
                      fit: BoxFit.cover,
                      fallback: Container(
                          color: _surfaceHigh,
                          child: const Icon(Icons.image_rounded,
                              color: _textLight, size: 60)),
                    ),
                  ),
                  // Gradient at bottom of hero
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Image counter dots
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(allImages.length, (i) {
                          final active = i == _selectedGalleryIndex;
                          return AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            width: active ? 20.0 : 6.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: active
                                  ? _primary
                                  : Colors.white
                                  .withValues(alpha: 0.50),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Body Content ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (p.status.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _primary.withValues(alpha: 0.30),
                                width: 1),
                          ),
                          child: Text(p.status,
                              style: const TextStyle(
                                  color: _primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),

                  if (p.category.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.category_rounded,
                          color: _textLight, size: 13),
                      const SizedBox(width: 5),
                      Text(p.category,
                          style: const TextStyle(
                              color: _textLight, fontSize: 13)),
                    ]),
                  ],

                  const SizedBox(height: 20),

                  // Info chips row
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (p.location.isNotEmpty)
                        _InfoChip(
                          icon: Icons.location_on_rounded,
                          label: p.location,
                        ),
                      if (p.client.isNotEmpty)
                        _InfoChip(
                          icon: Icons.person_rounded,
                          label: p.client,
                        ),
                      if (p.startDate.isNotEmpty)
                        _InfoChip(
                          icon: Icons.calendar_today_rounded,
                          label: p.startDate,
                        ),
                      if (p.endDate.isNotEmpty && p.endDate != p.startDate)
                        _InfoChip(
                          icon: Icons.event_available_rounded,
                          label: p.endDate,
                        ),
                    ],
                  ),

                  // Description
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'About This Project'),
                    const SizedBox(height: 12),
                    Text(
                      p.description,
                      style: const TextStyle(
                        color: _textMid,
                        fontSize: 14.5,
                        height: 1.65,
                      ),
                    ),
                  ],

                  // Gallery thumbnails
                  if (p.gallery.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'Project Gallery'),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: p.gallery.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final active = _selectedGalleryIndex ==
                              (i + 1); // +1 because cover is index 0
                          return GestureDetector(
                            onTap: () {
                              _galleryCtrl.animateToPage(
                                i + 1,
                                duration:
                                const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: active
                                      ? _primary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _NetImage(
                                  src: p.gallery[i].imagePath,
                                  fit: BoxFit.cover,
                                  fallback: Container(
                                      color: _surfaceHigh,
                                      child: const Icon(
                                          Icons.image_rounded,
                                          color: _textLight)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Contact CTA
                  _buildContactCTA(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _primary.withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: const Icon(Icons.handshake_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interested in a similar project?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Get in touch with our team today',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Contact Us',
                  style: TextStyle(
                      color: _primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: _textDark,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: Colors.grey.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primary, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: _textMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}