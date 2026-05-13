import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'package:fixco/features/authentication/login/pages/login.dart';
import 'package:fixco/features/booking/pages/booking_details.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand tokens (only primary color kept, rest neutral)
// ─────────────────────────────────────────────────────────────────────────────
const Color _primary = Color(0xFFE65100);
const Color _grey200  = Color(0xFFE0E0E0);
const Color _grey50   = Color(0xFFFAFAFA);

// Status colors (softer, still readable on white)
Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed': return const Color(0xFF2E7D32);
    case 'confirmed': return const Color(0xFF1565C0);
    case 'cancelled': return const Color(0xFFC62828);
    default:          return _primary;
  }
}

IconData _statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'completed': return Icons.task_alt_rounded;
    case 'confirmed': return Icons.shield_rounded;
    case 'cancelled': return Icons.remove_circle_rounded;
    default:          return Icons.pending_rounded;
  }
}

const _tabIcons = [
  Icons.hourglass_top_rounded,
  Icons.verified_user_rounded,
  Icons.workspace_premium_rounded,
  Icons.block_rounded,
];

const _tabColors = [
  _primary,          // pending
  Color(0xFF1565C0), // confirmed
  Color(0xFF2E7D32), // completed
  Color(0xFFC62828), // cancelled
];

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class BookingModel {
  final int id;
  final String service;
  final String dateTime;
  final String status;
  final Map<String, dynamic> raw;

  BookingModel({
    required this.id,
    required this.service,
    required this.dateTime,
    required this.status,
    required this.raw,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: int.parse(json['id'].toString()),
      service: json['service_name'] ?? 'Service',
      dateTime: "${json['booking_date_formatted']} • ${json['booking_time_formatted']}",
      status: _fmt(json['status']),
      raw: json,
    );
  }

  static String _fmt(String? s) {
    if (s == null || s.isEmpty) return 'Pending';
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Page
// ─────────────────────────────────────────────────────────────────────────────
class Booking extends StatefulWidget {
  const Booking({super.key});
  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> with TickerProviderStateMixin {
  int _selectedTab = 0;
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  static const _tabs = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];

  late final AnimationController _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _fadeAnim =
  CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
  late final Animation<Offset> _slideAnim =
  Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutQuart));

  late final AnimationController _listCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _entranceCtrl.forward();
    _init();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await UserSession.loadUser();
    await _fetchBookings();
  }

  Future<void> _fetchBookings({bool silent = false}) async {
    if (!UserSession.isLoggedIn()) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (!silent && mounted) setState(() => _isLoading = true);

    try {
      final data = await Api.getUserBookings(UserSession.userId!);
      if (!mounted) return;
      setState(() {
        _bookings = data.map((e) => BookingModel.fromJson(e)).toList();
        _isLoading = false;
        _isRefreshing = false;
      });
      _listCtrl.forward(from: 0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshAll() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _fetchBookings(silent: true);
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _onTabChanged(int i) {
    if (_selectedTab == i) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedTab = i);
    _listCtrl.forward(from: 0);
  }

  List<BookingModel> get _filtered => _bookings
      .where((b) => b.status.toLowerCase() == _tabs[_selectedTab].toLowerCase())
      .toList();

  Future<void> _handleCancel(BookingModel booking) async {
    final confirmed = await _showCancelDialog(booking);
    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final result = await Api.cancelBooking(
      bookingId: booking.id,
      userId: UserSession.userId!,
      reason: 'Cancelled by user from app',
    );
    if (!mounted) return;

    if (result['status'] == 'success') {
      _showSnack('Booking cancelled successfully', isError: false);
      await _fetchBookings(silent: true);
    } else {
      _showSnack(result['message'] ?? 'Failed to cancel booking', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showCancelDialog(BookingModel booking) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CancelDialog(booking: booking),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isGuest = !UserSession.isLoggedIn();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: _primary,
        backgroundColor: Colors.white,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(isGuest)),
                SliverToBoxAdapter(child: _buildFixedTabBar()),

                // Loading state
                if (_isLoading && !_isRefreshing)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: _primary)),
                  )

                // Guest not logged in
                else if (isGuest)
                  SliverFillRemaining(child: _buildGuestState())

                // Empty state (no bookings in this tab)
                else if (_filtered.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())

                  // List of bookings – each wrapped in a SliverToBoxAdapter
                  else
                    ..._buildSliverList(),

                SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFab(isGuest),
    );
  }

  List<Widget> _buildSliverList() {
    final list = _filtered;
    final children = <Widget>[];

    for (int i = 0; i < list.length; i++) {
      final delay = (i * 0.08).clamp(0.0, 0.4);
      final itemAnim = CurvedAnimation(
        parent: _listCtrl,
        curve: Interval(delay, (delay + 0.3).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      );

      children.add(
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: itemAnim,
            builder: (_, child) => FadeTransition(
              opacity: itemAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(itemAnim),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: _BookingCard(
                booking: list[i],
                onCancel: () => _handleCancel(list[i]),
                onViewDetails: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingDetails(data: list[i].raw)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return children;
  }

  Widget _buildHeader(bool isGuest) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withValues(alpha: 0.22), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: _primary)),
                  const SizedBox(width: 7),
                  const Text('MEDCO CONTRACTING',
                      style: TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 13),
            const Text('My Bookings',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.1, letterSpacing: -0.4)),
            const SizedBox(height: 5),
            Text(
              isGuest ? 'Login to manage your bookings' : 'Track & manage all your appointments',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: _grey50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _grey200, width: 1),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = _selectedTab == i;
            final color = _tabColors[i];
            final isFirst = i == 0;
            final isLast = i == _tabs.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onTabChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.fromLTRB(isFirst ? 4 : 2, 4, isLast ? 4 : 2, 4),
                  decoration: BoxDecoration(
                    color: active ? color.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: active ? Border.all(color: color.withValues(alpha: 0.5), width: 1) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_tabIcons[i], size: 19, color: active ? color : Colors.black54),
                      const SizedBox(height: 4),
                      Text(_tabs[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? color : Colors.black45,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: _primary.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            const Text('Login Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
            const SizedBox(height: 8),
            const Text('Please login to view and manage your bookings.',
                style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Login to Continue', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final tab = _tabs[_selectedTab];
    final color = _tabColors[_selectedTab];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_tabIcons[_selectedTab], size: 64, color: color.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No $tab Bookings', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Text('Your $tab bookings will appear here.', style: const TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(bool isGuest) {
    return FloatingActionButton.extended(
      onPressed: () {
        if (isGuest) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else {
          // Navigate to booking screen (adjust as needed)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking screen coming soon')));
        }
      },
      backgroundColor: _primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(isGuest ? 'Login to Book' : 'Book Now', style: const TextStyle(color: Colors.white)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Card
// ─────────────────────────────────────────────────────────────────────────────
class _BookingCard extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onCancel;
  final VoidCallback onViewDetails;

  const _BookingCard({
    required this.booking,
    required this.onCancel,
    required this.onViewDetails,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  Color get _cardStatusColor => _statusColor(widget.booking.status);

  @override
  Widget build(BuildContext context) {
    final isPending = widget.booking.status.toLowerCase() == 'pending';

    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) => _hoverCtrl.reverse(),
      onTapCancel: () => _hoverCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _grey200, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primary.withValues(alpha: 0.08),
                            border: Border.all(color: _primary.withValues(alpha: 0.2), width: 1),
                          ),
                          child: const Icon(Icons.build_rounded, color: _primary, size: 22),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.booking.service,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.tag_rounded, size: 12, color: Colors.black54),
                                const SizedBox(width: 3),
                                Text('Order: ', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                Text('#${widget.booking.id}',
                                    style: const TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w700)),
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.access_time_rounded, size: 12, color: Colors.black54),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(widget.booking.dateTime,
                                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _cardStatusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _cardStatusColor.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(widget.booking.status), size: 11, color: _cardStatusColor),
                              const SizedBox(width: 4),
                              Text(widget.booking.status,
                                  style: TextStyle(color: _cardStatusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(color: _grey200, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          _ActionButton(
                            label: 'View Details',
                            icon: Icons.arrow_outward_rounded,
                            color: _primary,
                            onTap: widget.onViewDetails,
                          ),
                          const Spacer(),
                          if (isPending)
                            _ActionButton(
                              label: 'Cancel',
                              icon: Icons.close_rounded,
                              color: const Color(0xFFC62828),
                              onTap: widget.onCancel,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: _cardStatusColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.color.withValues(alpha: 0.08),
            border: Border.all(color: widget.color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 13, color: widget.color),
            const SizedBox(width: 5),
            Text(widget.label, style: TextStyle(color: widget.color, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cancel Dialog (white background, black borders)
// ─────────────────────────────────────────────────────────────────────────────
class _CancelDialog extends StatelessWidget {
  final BookingModel booking;
  const _CancelDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: _grey200)),
      title: Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
        const SizedBox(width: 8),
        const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.w700)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to cancel this booking?', style: TextStyle(color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Service: ${booking.service}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const Text('This action cannot be undone.', style: TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Booking')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Yes, Cancel'),
        ),
      ],
    );
  }
}