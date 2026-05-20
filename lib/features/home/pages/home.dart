import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/features/home/models/service_model.dart';
import 'package:fixco/features/home/home_service_booking/home_service_booking.dart';
import 'package:fixco/features/home/sub_services/sub_services_bottom_sheet.dart';
import '../../gradient_scaffold.dart'; // gradient background

// ============================================================================
// IMAGE CACHE (unchanged)
// ============================================================================
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
    } catch (_) {
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
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

// ============================================================================
// LOCAL MODELS (unchanged)
// ============================================================================
class Offer {
  final String id, title, description, image;
  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });
  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
    id: j['id']?.toString() ?? '',
    title: j['title'] ?? j['name'] ?? '',
    description: j['description'] ?? '',
    image: j['image'] ?? j['data-image'] ?? '',
  );
}

// ============================================================================
// GLASS CARD – stateless, uses InkWell (no scale, no vibration)
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
// ARROW BUTTON (same as contact.dart)
// ============================================================================
class ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const ArrowButton({super.key, required this.icon, required this.onTap});

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
// DOTS INDICATOR (same as contact.dart)
// ============================================================================
class DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const DotsIndicator({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.white.withOpacity(0.30),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ============================================================================
// SVG ICON (copied from contact.dart)
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
      child: CustomPaint(painter: _SvgPainter(svgPath, size)),
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
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = sz.width / 24;

    switch (id) {
      case 'search':
        canvas.drawCircle(Offset(10 * s, 10 * s), 6 * s, paint);
        final line = Path()
          ..moveTo(14 * s, 14 * s)
          ..lineTo(21 * s, 21 * s);
        canvas.drawPath(line, paint);
        break;

      case 'offer':
        final tag = Path()
          ..moveTo(12 * s, 2 * s)
          ..lineTo(20 * s, 10 * s)
          ..lineTo(13 * s, 17 * s)
          ..cubicTo(12.2 * s, 17.8 * s, 11 * s, 17.8 * s, 10.2 * s, 17 * s)
          ..lineTo(3 * s, 10 * s)
          ..lineTo(3 * s, 4 * s)
          ..lineTo(9 * s, 4 * s)
          ..close();
        canvas.drawPath(tag, paint);
        canvas.drawCircle(Offset(7.5 * s, 7.5 * s), 1.0 * s,
            paint..style = PaintingStyle.fill);
        break;

      case 'services':
        final grid = Path()
          ..moveTo(4 * s, 4 * s)
          ..lineTo(10 * s, 4 * s)
          ..lineTo(10 * s, 10 * s)
          ..lineTo(4 * s, 10 * s)
          ..close()
          ..moveTo(14 * s, 4 * s)
          ..lineTo(20 * s, 4 * s)
          ..lineTo(20 * s, 10 * s)
          ..lineTo(14 * s, 10 * s)
          ..close()
          ..moveTo(4 * s, 14 * s)
          ..lineTo(10 * s, 14 * s)
          ..lineTo(10 * s, 20 * s)
          ..lineTo(4 * s, 20 * s)
          ..close()
          ..moveTo(14 * s, 14 * s)
          ..lineTo(20 * s, 14 * s)
          ..lineTo(20 * s, 20 * s)
          ..lineTo(14 * s, 20 * s)
          ..close();
        canvas.drawPath(grid, paint);
        break;

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
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
}

// ============================================================================
// TYPEWRITER TEXT
// ============================================================================
class TypewriterText extends StatefulWidget {
  final List<String> texts;
  final Duration typingSpeed;
  final Duration pauseDuration;
  final TextStyle? style;

  const TypewriterText({
    super.key,
    required this.texts,
    this.typingSpeed = const Duration(milliseconds: 100),
    this.pauseDuration = const Duration(seconds: 2),
    this.style,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _currentTextIndex = 0;
  String _displayText = '';
  bool _isDeleting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    final fullText = widget.texts[_currentTextIndex];
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (!mounted) return;
      setState(() {
        if (!_isDeleting) {
          if (_displayText.length < fullText.length) {
            _displayText = fullText.substring(0, _displayText.length + 1);
          } else {
            _isDeleting = true;
            timer.cancel();
            Future.delayed(widget.pauseDuration, () {
              if (mounted) _startDeleting();
            });
          }
        }
      });
    });
  }

  void _startDeleting() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (!mounted) return;
      setState(() {
        if (_displayText.isNotEmpty) {
          _displayText = _displayText.substring(0, _displayText.length - 1);
        } else {
          _isDeleting = false;
          _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
          timer.cancel();
          _startTyping();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ============================================================================
// HOME PAGE
// ============================================================================
class HomePage extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomePage({super.key, this.onProfileTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> _allServices = [];
  bool _servicesLoading = true;
  String? _servicesError;

  List<Offer> _offers = [];
  bool _offersLoading = true;
  String? _offersError;
  final PageController _offerCtrl = PageController(viewportFraction: 0.92, initialPage: 1000);
  int _offerPage = 0;
  Timer? _offerTimer;

  String _userName = '';
  String _userAddress = '';
  bool _isLoggedIn = false;

  bool _isRefreshing = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  String _committedQuery = '';

  final List<String> _typewriterTexts = [
    'Handyman',
    'Plumbing',
    'Electrician',
    'A/C Service',
    'Packers & Movers',
    'Painters',
  ];

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

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchOffers();
    _checkUserLogin();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _offerCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _checkUserLogin() async {
    await UserSession.loadUser();
    final loggedIn = UserSession.isLoggedIn();
    if (loggedIn && mounted) {
      setState(() => _isLoggedIn = true);
      await _fetchUserProfile();
    } else if (mounted) {
      setState(() => _isLoggedIn = false);
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await Api.getUserProfile(UserSession.userId!);
      if (response['status'] == 'success' && mounted) {
        final userData = response['user'];
        setState(() {
          _userName = userData['full_name'] ?? userData['name'] ?? userData['fullname'] ?? 'User';
          _userAddress = userData['address'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  void _startOfferTimer() {
    _offerTimer?.cancel();
    _offerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_offerCtrl.hasClients) return;
      _offerCtrl.nextPage(
          duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  void _commitSearch(String value) {
    final t = value.trim();
    setState(() {
      _searchQuery = t;
      _committedQuery = t;
    });
    _searchCtrl.text = t;
    _searchFocus.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _committedQuery = '';
    });
    _searchCtrl.clear();
    _searchFocus.unfocus();
  }

  Future<void> _refreshAll() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.wait([
      _fetchServices(showLoading: false),
      _fetchOffers(showLoading: false),
      _checkUserLogin(),
    ]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _fetchServices({bool showLoading = true}) async {
    if (showLoading) setState(() => _servicesLoading = true);
    try {
      final data = await Api.getServices();
      if (mounted) {
        setState(() {
          _allServices = data.map((j) => Service.fromJson(j)).toList();
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

  Future<void> _fetchOffers({bool showLoading = true}) async {
    if (showLoading) setState(() => _offersLoading = true);
    try {
      final data = await Api.getOffers();
      if (mounted) {
        setState(() {
          _offers = data.map((j) => Offer.fromJson(j)).toList();
          for (final o in _offers) {
            if (o.image.isNotEmpty) _resolveImageProvider(o.image);
          }
          _offersLoading = false;
          _offersError = null;
        });
        if (_offers.isNotEmpty) _startOfferTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _offersError = e.toString();
          _offersLoading = false;
        });
      }
    }
  }

  void _onProfileTap() {
    widget.onProfileTap?.call();
  }

  void _showSubServicesBottomSheet(String serviceId, String serviceName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubServicesBottomSheet(
        serviceId: int.parse(serviceId),
        serviceName: serviceName,
      ),
    );
  }

  // ==========================================================================
  // SECTION HEADER – simple text only (no pipe, no emoji) for Popular Services
  // ==========================================================================
  Widget _buildSimpleHeader(String title, {VoidCallback? onClear}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.18), width: 1.0),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEADER CONTENT – now uses glass cards and white text
  // ==========================================================================
  Widget _buildHeaderContent() {
    const onHeader = Colors.white;
    const onHeaderSub = Colors.white70;
    final showName = _isLoggedIn && _userName.isNotEmpty;
    final displayAddress = _userAddress.isNotEmpty ? _userAddress : 'Set your location';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Profile and Notification
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _onProfileTap,
                child: const _SvgIcon('person', size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: onHeader,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(text: 'Welcome, '),
                          if (showName)
                            TextSpan(
                              text: _userName,
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: onHeaderSub),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            displayAddress,
                            style: const TextStyle(fontSize: 11, color: onHeaderSub, fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {},
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: onHeader, size: 24),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final hasFocus = _searchFocus.hasFocus;
    const onHeader = Colors.white;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (!hasFocus && _searchCtrl.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: TypewriterText(
                texts: _typewriterTexts,
                typingSpeed: const Duration(milliseconds: 100),
                pauseDuration: const Duration(seconds: 2),
                style: TextStyle(color: onHeader.withOpacity(0.40), fontSize: 13),
              ),
            ),
          TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            style: const TextStyle(color: onHeader, fontSize: 13),
            textInputAction: TextInputAction.search,
            onSubmitted: _commitSearch,
            decoration: InputDecoration(
              hintText: '',
              prefixIcon: Icon(Icons.search_rounded, color: onHeader.withOpacity(0.55), size: 19),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                  onTap: _clearSearch,
                  child: Icon(Icons.close_rounded, color: onHeader.withOpacity(0.55), size: 17))
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DROPDOWN OVERLAY (glass style)
  // ==========================================================================
  Widget _buildDropdownOverlay() {
    final suggestions = _suggestions;
    final safeTop = MediaQuery.of(context).padding.top;
    const double headerContentH = 60 + 44 + 16; // rough estimate
    final double dropTop = safeTop + headerContentH + 8;

    return Positioned(
      top: dropTop,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: GlassCard(
          borderRadius: 14,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: suggestions.isEmpty
                  ? _dropdownEmpty()
                  : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: suggestions.length,
                itemBuilder: (_, i) => _DropdownItem(
                  service: suggestions[i],
                  isLast: i == suggestions.length - 1,
                  onTap: () => _commitSearch(suggestions[i].name),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownEmpty() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Icon(Icons.search_off_rounded, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(width: 10),
        Text('No services found', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ]),
    );
  }

  // ==========================================================================
  // OFFERS CAROUSEL (no OFFER badge, glass background)
  // ==========================================================================
  Widget _buildOffersCarousel() {
    if (_offersLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
          ),
        ),
      );
    }

    if (_offersError != null || _offers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          SizedBox(
            height: 185,
            child: PageView.builder(
              controller: _offerCtrl,
              onPageChanged: (p) => setState(() => _offerPage = p % _offers.length),
              itemBuilder: (_, i) {
                final offer = _offers[i % _offers.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _OfferCard(offer: offer),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _offerCtrl.previousPage(
                      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                ),
                DotsIndicator(count: _offers.length, current: _offerPage),
                ArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _offerCtrl.nextPage(
                      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SERVICES GRID (3 cards per row)
  // ==========================================================================
  Widget _buildServicesSliver(BuildContext context) {
    if (_servicesLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5))),
      );
    }

    if (_servicesError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _ErrorState(
            message: 'Could not load services',
            onRetry: () => _fetchServices(showLoading: true),
          ),
        ),
      );
    }

    final list = _gridServices;

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _EmptyState(message: 'No services found for\n"$_committedQuery"'),
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
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
              (_, i) => _ServiceCard(
            service: list[i],
            onTap: () => _showSubServicesBottomSheet(list[i].id, list[i].name),
          ),
          childCount: list.length,
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;

    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.10),
        child: Stack(
          children: [
            CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeaderContent()),
                if (_committedQuery.isEmpty)
                  SliverToBoxAdapter(child: _buildOffersCarousel()),
                SliverToBoxAdapter(
                  child: _buildSimpleHeader(
                    _committedQuery.isNotEmpty ? 'Results for "$_committedQuery"' : 'Popular Services',
                    onClear: _committedQuery.isNotEmpty ? _clearSearch : null,
                  ),
                ),
                _buildServicesSliver(context),
                SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
              ],
            ),
            if (_showDropdown) _buildDropdownOverlay(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED EMPTY / ERROR STATES (glass style)
// ============================================================================
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: Colors.white.withOpacity(0.4), size: 36),
          const SizedBox(height: 10),
          Text(message,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.redAccent.withOpacity(0.65), size: 32),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.20), width: 1.0),
              ),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DROPDOWN ITEM (glass)
// ============================================================================
class _DropdownItem extends StatelessWidget {
  final Service service;
  final bool isLast;
  final VoidCallback onTap;
  const _DropdownItem({required this.service, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.07))),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
                borderRadius: BorderRadius.circular(7),
              ),
              child: SizedBox(
                width: 34,
                height: 34,
                child: CachedImage(
                  imageData: service.image.isNotEmpty ? service.image : null,
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.build_rounded, color: Colors.white24, size: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(service.name,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.north_west_rounded, color: Colors.white38, size: 12),
        ]),
      ),
    );
  }
}

// ============================================================================
// OFFER CARD (glass, no OFFER badge, transparent blurry background)
// ============================================================================
class _OfferCard extends StatelessWidget {
  final Offer offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (offer.description.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${offer.title} — ${offer.description}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
            color: Colors.white.withOpacity(0.05), // glass background
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imageData: offer.image,
                fit: BoxFit.cover,
                fallback: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: const Icon(Icons.local_offer_rounded, color: Colors.white24, size: 36),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
              // Removed the OFFER badge – as requested
              Positioned(
                left: 13,
                right: 13,
                bottom: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (offer.title.isNotEmpty)
                      Text(offer.title,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (offer.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(offer.description,
                          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11, fontWeight: FontWeight.w400, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SERVICE CARD (glass, no icon border, gradient overlay)
// ============================================================================
class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imageData: service.image,
                fit: BoxFit.cover,
                fallback: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.70)],
                    stops: const [0.40, 1.0],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    service.name,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}