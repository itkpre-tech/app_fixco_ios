import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/features/home/widgets/home_all_projects.dart';
import 'package:fixco/features/home/widgets/home_projects_details.dart';
import '../models/service_model.dart';
import '../models/project_model.dart';
import '../models/offer_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_image_helper.dart';
import '../shared/home_ui_kit.dart';
import '../widgets/home_title_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_search_dropdown.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_promo_carousel.dart';
import '../widgets/home_offers_section.dart';
import '../widgets/home_service_grid.dart';
import '../widgets/home_projects_carousel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth helper
// ─────────────────────────────────────────────────────────────────────────────
class _Auth {
  static String? get currentUserName => null;
}

// ─────────────────────────────────────────────────────────────────────────────
// HomePage
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final String? userName;
  const HomePage({super.key, this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // ── data ──────────────────────────────────────────────────────────────────
  List<ServiceModel> _services     = [];
  bool _servicesLoading            = true;
  String? _servicesError;

  List<ProjectModel> _projects     = [];
  bool _projectsLoading            = true;
  String? _projectsError;

  List<OfferModel> _offers         = [];
  bool _offersLoading              = true;
  String? _offersError;

  bool _isRefreshing               = false;

  // ── search ────────────────────────────────────────────────────────────────
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery    = '';
  String _committedQuery = '';

  bool get _showDropdown => _searchFocus.hasFocus && !_servicesLoading;

  List<ServiceModel> get _suggestions {
    if (_searchQuery.isEmpty) return _services;
    final q = _searchQuery.toLowerCase();
    return _services.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  List<ServiceModel> get _gridServices {
    if (_committedQuery.isEmpty) return _services;
    final q = _committedQuery.toLowerCase();
    return _services.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  // ── carousels ─────────────────────────────────────────────────────────────
  late final PageController _promoCtrl   = PageController(viewportFraction: 0.88, initialPage: 1000);
  late final PageController _projectCtrl = PageController(viewportFraction: 0.90, initialPage: 1000);
  late final PageController _offersCtrl  = PageController(viewportFraction: 0.90, initialPage: 1000);

  int _promoPage   = 0;
  int _projectPage = 0;
  int _offersPage  = 0;

  Timer? _promoTimer;
  Timer? _projectTimer;
  Timer? _offersTimer;

  // ── animation controllers ─────────────────────────────────────────────────
  late final AnimationController _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _fadeAnim =
  CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
  late final Animation<Offset> _slideAnim =
  Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutQuart));

  late final AnimationController _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..repeat(reverse: true);
  late final Animation<double> _pulseAnim =
  Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  late final AnimationController _staggerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));
  late final Animation<double> _offersReveal =
  CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic));
  late final Animation<double> _servicesReveal =
  CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic));
  late final Animation<double> _projectsReveal =
  CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.50, 0.82, curve: Curves.easeOutCubic));
  late final Animation<double> _promoReveal =
  CurvedAnimation(parent: _staggerCtrl, curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic));

  // ── greeting ──────────────────────────────────────────────────────────────
  String get _greeting {
    final name = widget.userName ?? _Auth.currentUserName;
    if (name != null && name.isNotEmpty) return 'Hey, $name 👋';
    return 'Hey, Guest 👋';
  }

  // ── lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        _entranceCtrl.forward();
        _staggerCtrl.forward();
      }
    });
    _fetchServices();
    _fetchProjects();
    _fetchOffers();
    _startPromoTimer();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _staggerCtrl.dispose();
    _promoCtrl.dispose();
    _projectCtrl.dispose();
    _offersCtrl.dispose();
    _promoTimer?.cancel();
    _projectTimer?.cancel();
    _offersTimer?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── timers ────────────────────────────────────────────────────────────────
  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _promoCtrl.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    });
  }

  void _startProjectTimer() {
    _projectTimer?.cancel();
    _projectTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _projectCtrl.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    });
  }

  void _startOffersTimer() {
    _offersTimer?.cancel();
    if (_offers.isEmpty) return;
    _offersTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_offersCtrl.hasClients) return;
      _offersCtrl.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    });
  }

  // ── search actions ────────────────────────────────────────────────────────
  void _commitSearch(String v) {
    final q = v.trim();
    setState(() { _searchQuery = q; _committedQuery = q; });
    _searchCtrl.text = q;
    _searchFocus.unfocus();
  }

  void _clearSearch() {
    setState(() { _searchQuery = ''; _committedQuery = ''; });
    _searchCtrl.clear();
    _searchFocus.unfocus();
  }

  // ── refresh ───────────────────────────────────────────────────────────────
  Future<void> _refreshAll() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.wait([
      _fetchServices(showLoading: false),
      _fetchProjects(showLoading: false, force: true),
      _fetchOffers(showLoading: false),
    ]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  // ── fetch ─────────────────────────────────────────────────────────────────
  Future<void> _fetchServices({bool showLoading = true}) async {
    if (showLoading) setState(() => _servicesLoading = true);
    try {
      final data = await Api.getServices();
      if (!mounted) return;
      setState(() {
        _services = data.map((j) => ServiceModel.fromJson(j)).toList();
        for (final s in _services) { if (s.image.isNotEmpty) resolveImage(s.image); }
        _servicesLoading = false;
        _servicesError   = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _servicesError = e.toString(); _servicesLoading = false; });
    }
  }

  Future<void> _fetchProjects({bool showLoading = true, bool force = false}) async {
    if (showLoading && !force) setState(() => _projectsLoading = true);
    try {
      final data = await Api.getProjects();
      if (!mounted) return;
      setState(() {
        _projects = data.map((j) => ProjectModel.fromJson(j)).toList();
        for (final p in _projects) { if (p.coverImage.isNotEmpty) resolveImage(p.coverImage); }
        _projectsLoading = false;
        _projectsError   = null;
      });
      if (_projects.isNotEmpty) _startProjectTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() { _projectsError = e.toString(); _projectsLoading = false; });
    }
  }

  Future<void> _fetchOffers({bool showLoading = true}) async {
    if (showLoading) setState(() => _offersLoading = true);
    try {
      final data = await Api.getOffers();
      if (!mounted) return;
      setState(() {
        _offers = data.map((j) => OfferModel.fromJson(j as Map<String, dynamic>)).toList();
        for (final o in _offers) { if (o.image.isNotEmpty) resolveImage(o.image); }
        _offersLoading = false;
        _offersError   = null;
      });
      if (_offers.isNotEmpty) _startOffersTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() { _offersError = e.toString(); _offersLoading = false; });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DROPDOWN HEIGHT helper
  // ─────────────────────────────────────────────────────────────────────────
  double get _dropdownHeight {
    final c = _suggestions.length.clamp(0, 7);
    return c == 0 ? 62.0 : (c * 54.0) + 16;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _searchFocus.unfocus(),
      child: Scaffold(
        backgroundColor: kBgWhite,
        body: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: RefreshIndicator(
                  onRefresh: _refreshAll,
                  color: kPrimary,
                  backgroundColor: Colors.white,
                  child: CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── Title Bar ─────────────────────────────────────
                      SliverToBoxAdapter(
                        child: HomeTitleBar(greeting: _greeting, pulseAnim: _pulseAnim),
                      ),

                      // ── Search Bar ────────────────────────────────────
                      SliverToBoxAdapter(
                        child: HomeSearchBar(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          searchQuery: _searchQuery,
                          onSubmitted: _commitSearch,
                          onClear: _clearSearch,
                        ),
                      ),

                      // Spacer for dropdown overlay
                      if (_showDropdown)
                        SliverToBoxAdapter(child: SizedBox(height: _dropdownHeight)),

                      // ── Offers ────────────────────────────────────────
                      if (_committedQuery.isEmpty && (_offers.isNotEmpty || _offersLoading))
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _offersReveal,
                            child: HomeSectionHeader(
                              title: 'Special Offers',
                              icon: Icons.local_fire_department_rounded,
                              iconColor: kPrimary,
                            ),
                          ),
                        ),
                      if (_committedQuery.isEmpty)
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _offersReveal,
                            child: HomeOffersSection(
                              isLoading: _offersLoading,
                              error: _offersError,
                              offers: _offers,
                              controller: _offersCtrl,
                              currentPage: _offersPage,
                              onPageChanged: (p) => setState(() => _offersPage = p),
                              onRetry: () => _fetchOffers(),
                            ),
                          ),
                        ),

                      // ── Services Header ───────────────────────────────
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _servicesReveal,
                          child: HomeSectionHeader(
                            title: _committedQuery.isEmpty
                                ? 'Popular Services'
                                : 'Results for "$_committedQuery"',
                            trailing: _committedQuery.isNotEmpty
                                ? PillButton(
                              label: 'Clear ✕',
                              textColor: Colors.redAccent,
                              borderColor: Colors.red.withValues(alpha: 0.35),
                              onTap: _clearSearch,
                            )
                                : null,
                          ),
                        ),
                      ),

                      // ── Services Grid ─────────────────────────────────
                      SliverFadeTransition(
                        opacity: _servicesReveal,
                        sliver: HomeServicesGrid(
                          isLoading: _servicesLoading,
                          error: _servicesError,
                          services: _gridServices,
                          committedQuery: _committedQuery,
                          onRetry: () => _fetchServices(),
                          onClearSearch: _clearSearch,
                        ),
                      ),

                      // ── Projects ──────────────────────────────────────
                      if (_committedQuery.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _projectsReveal,
                            child: HomeSectionHeader(
                              title: 'Our Projects',
                              trailing: ProjectsSeeAll(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AllProjectsPage()),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _projectsReveal,
                            child: HomeProjectsCarousel(
                              isLoading: _projectsLoading,
                              error: _projectsError,
                              projects: _projects,
                              controller: _projectCtrl,
                              currentPage: _projectPage,
                              onPageChanged: (p) => setState(() => _projectPage = p),
                              onRetry: () => _fetchProjects(force: true),
                              onViewProject: (id) => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ProjectDetailPage(projectId: id)),
                              ),
                            ),
                          ),
                        ),

                        // ── Promo Carousel ────────────────────────────
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _promoReveal,
                            child: HomeSectionHeader(
                              title: 'Explore More',
                              icon: Icons.auto_awesome_rounded,
                              iconColor: kPrimary,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _promoReveal,
                            child: HomePromoCarousel(
                              controller: _promoCtrl,
                              currentPage: _promoPage,
                              onPageChanged: (p) => setState(() => _promoPage = p),
                            ),
                          ),
                        ),
                      ],

                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Dropdown overlay ──────────────────────────────────────
            if (_showDropdown)
              HomeSearchDropdown(
                suggestions: _suggestions,
                topOffset: MediaQuery.of(context).padding.top + 202,
                onSelect: _commitSearch,
              ),
          ],
        ),
      ),
    );
  }
}