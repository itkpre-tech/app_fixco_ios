import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/features/authentication/register/pages/register.dart';
import 'package:fixco/features/services/pages/services_details.dart';

final Map<String, ImageProvider> _imageProviderCache = {};

ImageProvider _resolveImageProvider(String imageData) {
  if (_imageProviderCache.containsKey(imageData)) {
    return _imageProviderCache[imageData]!;
  }
  ImageProvider provider;
  if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
    provider = NetworkImage(imageData);
  } else if (imageData.startsWith('data:image')) {
    try {
      final bytes = base64Decode(imageData.split(',').last);
      provider = MemoryImage(bytes);
    } catch (e) {
      // fix 1: _ → e
      provider = const NetworkImage('');
    }
  } else {
    provider = NetworkImage('http://admin.medco-contracting.com$imageData');
  }
  _imageProviderCache[imageData] = provider;
  return provider;
}

class CachedImage extends StatelessWidget {
  final String? imageData;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallback;

  const CachedImage({
    super.key,
    required this.imageData,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (imageData == null || imageData!.isEmpty) return fallback;
    final provider = _resolveImageProvider(imageData!);
    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) =>
          fallback, // fix 2: ___ → named
    );
  }
}

class Service {
  final String id, name, image;

  Service({required this.id, required this.name, required this.image});

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    image: json['image'] ?? '',
  );
}

class Project {
  final String id, title, coverImage;

  Project({required this.id, required this.title, required this.coverImage});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    coverImage: json['cover_image'] ?? '',
  );
}

class PromoData {
  final String label, title, subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const PromoData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}

const _promos = [
  PromoData(
    label: 'WELCOME OFFER',
    title: 'Exclusive Discount\nOn Your First\nBooking',
    subtitle: 'Book before the month ends',
    icon: Icons.local_offer_rounded,
    gradient: [Color(0xFF1A237E), Color(0xFF283593)],
    accent: Color(0xFF7986CB),
  ),
  PromoData(
    label: 'NEW SERVICE',
    title: 'Professional\nPainting\nServices',
    subtitle: 'Transform your space with expert painters',
    icon: Icons.format_paint_rounded,
    gradient: [Color(0xFF004D40), Color(0xFF00695C)],
    accent: Color(0xFF4DB6AC),
  ),
  PromoData(
    label: 'NEW SERVICE',
    title: 'Packers &\nMovers\nService',
    subtitle: 'Safe and hassle-free relocation',
    icon: Icons.local_shipping_rounded,
    gradient: [Color(0xFF37474F), Color(0xFF455A64)],
    accent: Color(0xFF90A4AE),
  ),
  PromoData(
    label: 'NEW SERVICE',
    title: 'Expert\nHandyman\nServices',
    subtitle: 'Quick fixes for all your home needs',
    icon: Icons.handyman_rounded,
    gradient: [Color(0xFFBF360C), Color(0xFFD84315)],
    accent: Color(0xFFFF8A65),
  ),
  PromoData(
    label: 'NEW SERVICE',
    title: 'Reliable\nPlumbing\nSolutions',
    subtitle: 'Fast and efficient plumbing services',
    icon: Icons.plumbing_rounded,
    gradient: [Color(0xFF0D47A1), Color(0xFF1565C0)],
    accent: Color(0xFF64B5F6),
  ),
  PromoData(
    label: 'NEW SERVICE',
    title: 'Certified\nElectrical\nWorks',
    subtitle: 'Safe and professional electricians',
    icon: Icons.bolt_rounded,
    gradient: [Color(0xFFF57F17), Color(0xFFF9A825)],
    accent: Color(0xFFFFF176),
  ),
  PromoData(
    label: 'NEW SERVICE',
    title: 'AC Service &\nRepair',
    subtitle: 'Stay cool with expert AC maintenance',
    icon: Icons.ac_unit_rounded,
    gradient: [Color(0xFF01579B), Color(0xFF0277BD)],
    accent: Color(0xFF4FC3F7),
  ),
  PromoData(
    label: 'PREMIUM CARE',
    title: 'Annual\nMaintenance\nContracts',
    subtitle: 'Hassle-free home maintenance all year',
    icon: Icons.verified_rounded,
    gradient: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    accent: Color(0xFFA5D6A7),
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> _allServices = [];
  bool _servicesLoading = true;
  String? _servicesError;

  List<Project> _projects = [];
  bool _projectsLoading = true;
  String? _projectsError;

  bool _isRefreshing = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _searchQuery = '';
  String _committedQuery = '';

  bool get _showDropdown => _searchFocus.hasFocus && !_servicesLoading;

  List<Service> get _suggestions {
    if (_searchQuery.isEmpty) return _allServices;
    final q = _searchQuery.toLowerCase();
    return _allServices.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  List<Service> get _gridServices {
    if (_committedQuery.isEmpty) return _allServices;
    final q = _committedQuery.toLowerCase();
    return _allServices.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  final PageController _promoController = PageController(
    viewportFraction: 0.88,
    initialPage: 1000,
  );
  int _promoPage = 0;
  Timer? _promoTimer;

  final PageController _projectController = PageController(
    viewportFraction: 0.92,
    initialPage: 1000,
  );
  int _projectPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchProjects();
    _startPromoTimer();

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });

    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    _projectController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted) return;
      _promoController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _commitSearch(String value) {
    final trimmed = value.trim();
    setState(() {
      _searchQuery = trimmed;
      _committedQuery = trimmed;
    });
    _searchController.text = trimmed;
    _searchFocus.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _committedQuery = '';
    });
    _searchController.clear();
    _searchFocus.unfocus();
  }

  Future<void> _refreshAll() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.wait([
      _fetchServices(showLoading: false),
      _fetchProjects(showLoading: false, forceRefresh: true),
    ]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _fetchServices({bool showLoading = true}) async {
    if (showLoading) setState(() => _servicesLoading = true);
    try {
      final data = await Api.getServices();
      if (mounted) {
        setState(() {
          _allServices = data.map((json) => Service.fromJson(json)).toList();
          for (final s in _allServices) {
            if (s.image.isNotEmpty) _resolveImageProvider(s.image);
          }
          _servicesLoading = false;
          _servicesError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _servicesError = e.toString();
          _servicesLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProjects({
    bool showLoading = true,
    bool forceRefresh = false,
  }) async {
    if (showLoading && !forceRefresh) setState(() => _projectsLoading = true);
    try {
      final data = await Api.getProjects();
      if (mounted) {
        setState(() {
          _projects = data.map((json) => Project.fromJson(json)).toList();
          for (final p in _projects) {
            if (p.coverImage.isNotEmpty) _resolveImageProvider(p.coverImage);
          }
          _projectsLoading = false;
          _projectsError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _projectsError = e.toString();
          _projectsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _searchFocus.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshAll,
              color: Colors.white,
              backgroundColor: Colors.black54,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(child: _buildTitleBar()),
                  SliverToBoxAdapter(child: _buildSearchBar()),

                  if (_showDropdown)
                    SliverToBoxAdapter(
                      child: SizedBox(height: _dropdownHeight),
                    ),
                  if (_committedQuery.isEmpty)
                    SliverToBoxAdapter(child: _buildPromoCarousel()),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _committedQuery.isEmpty
                                  ? 'Popular Services'
                                  : 'Results for "$_committedQuery"',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_committedQuery.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.4),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Clear ✕',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  _buildServicesSliver(),

                  if (_committedQuery.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Our Projects',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/all-projects'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'See All Projects →',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildProjectsCarousel()),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

            if (_showDropdown) _buildDropdownOverlay(),
          ],
        ),
      ),
    );
  }

  double get _dropdownHeight {
    final count = _suggestions.length.clamp(0, 7);
    if (count == 0) return 60.0;
    return (count * 52.0) + 16;
  }

  Widget _buildDropdownOverlay() {
    final suggestions = _suggestions;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 198,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 380),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: suggestions.isEmpty
                ? _dropdownEmptyRow()
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final s = suggestions[index];
                      final isLast = index == suggestions.length - 1;
                      return DropdownItem(
                        service: s,
                        isLast: isLast,
                        onTap: () => _commitSearch(s.name),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownEmptyRow() {
    return const Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: Colors.white38, size: 18),
          SizedBox(width: 10),
          Text(
            'No services found',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MEDCO CONTRACTING', // ignore: spell_check_comments
                      style: TextStyle(
                        color: Color(0xFF90CAF9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Good morning 👋',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'How can we assist you today?',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocus.hasFocus
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          textInputAction: TextInputAction.search,
          onSubmitted: (v) => _commitSearch(v),
          decoration: InputDecoration(
            hintText: 'Search services...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: _clearSearch,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSliver() {
    if (_servicesLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }
    if (_servicesError != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _servicesError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _fetchServices(showLoading: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final list = _gridServices;

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                color: Colors.white24,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No service found for "$_committedQuery"',
                style: const TextStyle(color: Colors.white38, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Show all services',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ServiceCard(service: list[index]),
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _promoController,
            onPageChanged: (page) =>
                setState(() => _promoPage = page % _promos.length),
            itemBuilder: (context, index) {
              final promo = _promos[index % _promos.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: PromoCard(promo: promo),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _promoController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
              ),
              DotsIndicator(count: _promos.length, current: _promoPage),
              ArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _promoController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsCarousel() {
    if (_projectsLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_projectsError != null) {
      return Center(
        child: Column(
          children: [
            Text(_projectsError!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () =>
                  _fetchProjects(showLoading: true, forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('No projects yet', style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _projectController,
            onPageChanged: (page) =>
                setState(() => _projectPage = page % _projects.length),
            itemBuilder: (context, index) {
              final project = _projects[index % _projects.length];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ProjectCard(project: project),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        DotsIndicator(count: _projects.length, current: _projectPage),
        const SizedBox(height: 6),
      ],
    );
  }
}

class DropdownItem extends StatelessWidget {
  final Service service;
  final bool isLast;
  final VoidCallback onTap;

  const DropdownItem({
    super.key,
    required this.service,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 36,
                height: 36,
                child: CachedImage(
                  imageData: service.image.isNotEmpty ? service.image : null,
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.build_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.north_west_rounded,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const DotsIndicator({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ArrowButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  final PromoData promo;

  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: promo.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: promo.gradient.first.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: promo.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.label,
                    style: TextStyle(
                      color: promo.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  promo.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  promo.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: promo.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(promo.icon, color: promo.accent, size: 36),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ServiceDetails(serviceId: service.id),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(
              imageData: service.image,
              fit: BoxFit.cover,
              fallback: Container(
                color: Colors.grey[850],
                child: Icon(
                  Icons.build_rounded,
                  color: Colors.grey[600],
                  size: 28,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  service.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[900],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedImage(
              imageData: project.coverImage,
              fit: BoxFit.cover,
              fallback: Container(
                color: Colors.grey[850],
                child: Icon(
                  Icons.image_rounded,
                  color: Colors.grey[700],
                  size: 50,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                project.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
