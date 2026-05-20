import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/features/home/sub_services/sub_service_categories_bottom_sheet.dart';
import 'package:fixco/features/home/sub_services/service_category_details_bottom_sheet.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/services/user_session.dart';
import 'booking_payment_bottom_sheet.dart';
import 'booking_receipt_details_bottom_sheet.dart';
import '../../gradient_scaffold.dart';

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
// SVG ICONS (copied from contact.dart)
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
      case 'cart':
        final cart = Path()
          ..moveTo(6 * s, 19 * s)
          ..cubicTo(6 * s, 19.8 * s, 6.7 * s, 20.5 * s, 7.5 * s, 20.5 * s)
          ..cubicTo(8.3 * s, 20.5 * s, 9 * s, 19.8 * s, 9 * s, 19 * s)
          ..cubicTo(9 * s, 18.2 * s, 8.3 * s, 17.5 * s, 7.5 * s, 17.5 * s)
          ..cubicTo(6.7 * s, 17.5 * s, 6 * s, 18.2 * s, 6 * s, 19 * s)
          ..close()
          ..moveTo(16 * s, 19 * s)
          ..cubicTo(16 * s, 19.8 * s, 16.7 * s, 20.5 * s, 17.5 * s, 20.5 * s)
          ..cubicTo(18.3 * s, 20.5 * s, 19 * s, 19.8 * s, 19 * s, 19 * s)
          ..cubicTo(19 * s, 18.2 * s, 18.3 * s, 17.5 * s, 17.5 * s, 17.5 * s)
          ..cubicTo(16.7 * s, 17.5 * s, 16 * s, 18.2 * s, 16 * s, 19 * s)
          ..close()
          ..moveTo(5 * s, 4 * s)
          ..lineTo(21 * s, 4 * s)
          ..lineTo(19 * s, 14 * s)
          ..lineTo(7 * s, 14 * s)
          ..close();
        canvas.drawPath(cart, paint);
        break;

      case 'bookings':
        final book = Path()
          ..moveTo(4 * s, 4 * s)
          ..lineTo(20 * s, 4 * s)
          ..lineTo(20 * s, 20 * s)
          ..lineTo(4 * s, 20 * s)
          ..close()
          ..moveTo(8 * s, 8 * s)
          ..lineTo(16 * s, 8 * s)
          ..moveTo(8 * s, 12 * s)
          ..lineTo(16 * s, 12 * s)
          ..moveTo(8 * s, 16 * s)
          ..lineTo(13 * s, 16 * s);
        canvas.drawPath(book, paint);
        break;

      case 'delete':
        final trash = Path()
          ..moveTo(6 * s, 6 * s)
          ..lineTo(18 * s, 6 * s)
          ..lineTo(17 * s, 19 * s)
          ..lineTo(7 * s, 19 * s)
          ..close()
          ..moveTo(9 * s, 9 * s)
          ..lineTo(9 * s, 16 * s)
          ..moveTo(12 * s, 9 * s)
          ..lineTo(12 * s, 16 * s)
          ..moveTo(15 * s, 9 * s)
          ..lineTo(15 * s, 16 * s)
          ..moveTo(4 * s, 6 * s)
          ..lineTo(20 * s, 6 * s);
        canvas.drawPath(trash, paint);
        break;

      case 'pending':
        final pending = Path()
          ..moveTo(12 * s, 6 * s)
          ..lineTo(12 * s, 12 * s)
          ..lineTo(16 * s, 14 * s)
          ..moveTo(12 * s, 2 * s)
          ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
          ..cubicTo(2 * s, 17.5 * s, 6.5 * s, 22 * s, 12 * s, 22 * s)
          ..cubicTo(17.5 * s, 22 * s, 22 * s, 17.5 * s, 22 * s, 12 * s)
          ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
          ..close();
        canvas.drawPath(pending, paint);
        break;

      case 'confirmed':
        final confirmed = Path()
          ..moveTo(9 * s, 12 * s)
          ..lineTo(11 * s, 14 * s)
          ..lineTo(15 * s, 9 * s)
          ..moveTo(12 * s, 2 * s)
          ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
          ..cubicTo(2 * s, 17.5 * s, 6.5 * s, 22 * s, 12 * s, 22 * s)
          ..cubicTo(17.5 * s, 22 * s, 22 * s, 17.5 * s, 22 * s, 12 * s)
          ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
          ..close();
        canvas.drawPath(confirmed, paint);
        break;

      case 'completed':
        final completed = Path()
          ..moveTo(8 * s, 12 * s)
          ..lineTo(12 * s, 16 * s)
          ..lineTo(18 * s, 8 * s)
          ..moveTo(12 * s, 2 * s)
          ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
          ..cubicTo(2 * s, 17.5 * s, 6.5 * s, 22 * s, 12 * s, 22 * s)
          ..cubicTo(17.5 * s, 22 * s, 22 * s, 17.5 * s, 22 * s, 12 * s)
          ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
          ..close();
        canvas.drawPath(completed, paint);
        break;

      case 'send':
        final send = Path()
          ..moveTo(3 * s, 12 * s)
          ..lineTo(21 * s, 3 * s)
          ..lineTo(12 * s, 21 * s)
          ..lineTo(9 * s, 15 * s)
          ..lineTo(15 * s, 9 * s)
          ..lineTo(9 * s, 12 * s);
        canvas.drawPath(send, paint);
        break;

      case 'close':
        final close = Path()
          ..moveTo(6 * s, 6 * s)
          ..lineTo(18 * s, 18 * s)
          ..moveTo(18 * s, 6 * s)
          ..lineTo(6 * s, 18 * s);
        canvas.drawPath(close, paint);
        break;

      case 'chat':
        final chat = Path()
          ..moveTo(4 * s, 20 * s)
          ..lineTo(9 * s, 17 * s)
          ..lineTo(18 * s, 17 * s)
          ..cubicTo(19.7 * s, 17 * s, 21 * s, 15.7 * s, 21 * s, 14 * s)
          ..lineTo(21 * s, 7 * s)
          ..cubicTo(21 * s, 5.3 * s, 19.7 * s, 4 * s, 18 * s, 4 * s)
          ..lineTo(6 * s, 4 * s)
          ..cubicTo(4.3 * s, 4 * s, 3 * s, 5.3 * s, 3 * s, 7 * s)
          ..lineTo(3 * s, 17 * s)
          ..lineTo(4 * s, 20 * s)
          ..close();
        canvas.drawPath(chat, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
}

// ============================================================================
// BookingModel (unchanged)
// ============================================================================
class BookingModel {
  final int id;
  final String serviceName;
  final String subServiceName;
  final String categoryName;
  final String status;
  final double amount;
  final String paymentStatus;
  final String? notes;
  final String? adminReply;
  final String? replyDate;
  final String? image;
  final int? serviceId;
  final int? subServiceId;
  final int? categoryId;
  final Map<String, dynamic> raw;

  BookingModel({
    required this.id,
    required this.serviceName,
    required this.subServiceName,
    required this.categoryName,
    required this.status,
    required this.amount,
    required this.paymentStatus,
    this.notes,
    this.adminReply,
    this.replyDate,
    this.image,
    this.serviceId,
    this.subServiceId,
    this.categoryId,
    required this.raw,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: int.parse(json['id'].toString()),
      serviceName: json['service_name']?.toString() ?? 'Service',
      subServiceName: json['sub_service_name']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      status: _fmt(json['status']?.toString()),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ??
          double.tryParse(json['service_price']?.toString() ?? '0') ??
          0.0,
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      adminReply: json['admin_reply']?.toString(),
      replyDate: json['reply_date']?.toString(),
      image: json['image']?.toString() ?? json['category_image']?.toString(),
      serviceId: int.tryParse(json['service_id']?.toString() ?? '0'),
      subServiceId: int.tryParse(json['sub_service_id']?.toString() ?? '0'),
      categoryId: int.tryParse(json['category_id']?.toString() ??
          json['sub_service_category_id']?.toString() ??
          '0'),
      raw: json,
    );
  }

  static String _fmt(String? s) {
    if (s == null || s.isEmpty) return 'Pending';
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

// ============================================================================
// Booking Page – now uses CustomScrollView for scrollable title & navlinks
// ============================================================================
class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  int _currentTabIndex = 0; // 0 = Cart, 1 = Bookings

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: () async {},
        color: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.10),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Title (same as contact.dart)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: const Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            // Navbuttons (Cart / Bookings)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _NavButton(
                      icon: 'cart',
                      label: 'Cart',
                      isSelected: _currentTabIndex == 0,
                      onTap: () => setState(() => _currentTabIndex = 0),
                    ),
                    const SizedBox(width: 12),
                    _NavButton(
                      icon: 'bookings',
                      label: 'Bookings',
                      isSelected: _currentTabIndex == 1,
                      onTap: () => setState(() => _currentTabIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Tab content (fills remaining space but will scroll with its own content)
            SliverFillRemaining(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  CartTab(onCheckoutSuccess: () => setState(() => _currentTabIndex = 1)),
                  const BookingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red[800] : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? Colors.red[800]! : Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SvgIcon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
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
// CART TAB – with inline note field, centered image, only category name
// ============================================================================
class CartTab extends StatefulWidget {
  final VoidCallback? onCheckoutSuccess;
  const CartTab({super.key, this.onCheckoutSuccess});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  late final CartManager _cart;
  bool _isCheckingOut = false;
  String? _checkoutError;
  Map<int, TextEditingController> _noteControllers = {};
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Set<int> _selectedItemIndices = {};

  @override
  void initState() {
    super.initState();
    _cart = CartManager();
    _cart.addListener(_onCartChanged);
    for (var item in _cart.items) {
      final id = item['id'] as int;
      if (!_noteControllers.containsKey(id)) {
        _noteControllers[id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _noteControllers.values) {
      c.dispose();
    }
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {
        // Add missing controllers for new items
        for (var item in _cart.items) {
          final id = item['id'] as int;
          if (!_noteControllers.containsKey(id)) {
            _noteControllers[id] = TextEditingController();
          }
        }
        // Remove controllers for deleted items
        final currentIds = _cart.items.map((e) => e['id'] as int).toSet();
        _noteControllers.removeWhere((key, value) => !currentIds.contains(key));
        _selectedItemIndices.removeWhere((idx) => idx >= _cart.items.length);
      });
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedItemIndices.contains(index)) {
        _selectedItemIndices.remove(index);
      } else {
        _selectedItemIndices.add(index);
      }
    });
  }

  void _removeItem(int index) {
    final itemId = _cart.items[index]['id'] as int;
    _cart.removeItem(index);
    _noteControllers.remove(itemId);
    _selectedItemIndices.remove(index);
    final newSelected = <int>{};
    for (var i in _selectedItemIndices) {
      if (i > index) newSelected.add(i - 1);
      else newSelected.add(i);
    }
    _selectedItemIndices = newSelected;
  }

  void _showDetails(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceCategoryBookingSheet(category: category),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _checkout() async {
    final selectedItems = _selectedItemIndices.map((i) => _cart.items[i]).toList();
    if (selectedItems.isEmpty) {
      _showError('Please select at least one item to checkout.');
      return;
    }
    if (!UserSession.isLoggedIn()) {
      _showError('Please log in to place a booking.');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showError('Please select a booking date and time first.');
      return;
    }

    setState(() {
      _isCheckingOut = true;
      _checkoutError = null;
    });

    final bookingDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    final bookingTime =
        "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";
    final int userId = UserSession.userId!;

    int successCount = 0;
    final List<String> errors = [];

    for (final item in selectedItems) {
      final int? serviceId = int.tryParse(item['service_id']?.toString() ?? '');
      final int? subServiceId = int.tryParse(item['sub_service_id']?.toString() ?? '');
      final int? categoryId = item['id'] as int?;
      final int itemId = categoryId ?? 0;
      final String note = _noteControllers[itemId]?.text.trim() ?? '';

      if (serviceId == null) {
        errors.add('${item['name'] ?? 'Item'}: missing service_id');
        continue;
      }

      final result = await Api.createBooking(
        userId: userId,
        serviceId: serviceId,
        subServiceId: subServiceId,
        subServiceCategoryId: categoryId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        notes: note.isNotEmpty ? note : null,
      );

      if (result['status'] == 'success') successCount++;
      else errors.add('${item['name'] ?? 'Item'}: ${result['message'] ?? 'Failed'}');
    }

    if (!mounted) return;

    if (successCount > 0) {
      for (int i = _cart.items.length - 1; i >= 0; i--) {
        if (selectedItems.contains(_cart.items[i])) {
          _cart.removeItem(i);
        }
      }
      _noteControllers.clear();
      _selectedItemIndices.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _isCheckingOut = false;
      });
      final msg = errors.isEmpty
          ? '$successCount booking${successCount > 1 ? 's' : ''} placed successfully!'
          : '$successCount booking${successCount > 1 ? 's' : ''} placed. ${errors.length} failed.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: errors.isEmpty ? Colors.green[700] : Colors.red[800],
          behavior: SnackBarBehavior.floating));
      widget.onCheckoutSuccess?.call();
    } else {
      setState(() {
        _checkoutError = errors.isNotEmpty ? errors.join('\n') : 'All bookings failed. Please try again.';
        _isCheckingOut = false;
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red[800], behavior: SnackBarBehavior.floating));
  }

  double get _selectedTotal {
    double sum = 0.0;
    for (var i in _selectedItemIndices) {
      final price = double.tryParse(_cart.items[i]['price']?.toString() ?? '0') ?? 0.0;
      sum += price;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final hasSelection = _selectedItemIndices.isNotEmpty;
    final selectedTotal = _selectedTotal;

    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? Center(
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SvgIcon('cart', size: 48),
                  const SizedBox(height: 16),
                  const Text('Cart is empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Add services from the categories page.',
                      style: TextStyle(fontSize: 13, color: Colors.white60)),
                ],
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemId = item['id'] as int;
              final controller = _noteControllers[itemId] ?? TextEditingController();
              final isSelected = _selectedItemIndices.contains(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleSelection(index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red[800] : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: isSelected ? Colors.red[800]! : Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Centered image
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
                                  child: CachedImageCat(
                                    imageData: item['image']?.toString() ?? '',
                                    fit: BoxFit.cover,
                                    fallback: const Icon(Icons.category_outlined, size: 40, color: Colors.white38),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Only category name (no service/sub-service)
                                  Text(item['name']?.toString() ?? 'Unnamed',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('${(double.tryParse(item['price']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)} AED',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green)),
                                  const SizedBox(height: 8),
                                  // Inline note field
                                  TextField(
                                    controller: controller,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Add a note...',
                                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.08),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      isDense: true,
                                    ),
                                    onChanged: (val) {
                                      // No extra state needed – controller updates itself
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _removeItem(index),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: _SvgIcon('delete', size: 16),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _showDetails(item),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (items.isNotEmpty)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _selectedDate != null ? Colors.red[800]! : Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.red[800]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                                        : 'Select Date',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedDate != null ? Colors.white : Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _selectedTime != null ? Colors.red[800]! : Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.red[800]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'Select Time',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedTime != null ? Colors.white : Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: !hasSelection
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_box_outline_blank_rounded, size: 18, color: Colors.white38),
                      const SizedBox(width: 8),
                      const Text('Select items to checkout',
                          style: TextStyle(fontSize: 13, color: Colors.white54)),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${_selectedItemIndices.length} item${_selectedItemIndices.length > 1 ? 's' : ''} selected',
                              style: const TextStyle(fontSize: 12, color: Colors.white54)),
                          Text('${selectedTotal.toStringAsFixed(2)} AED',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.green)),
                        ],
                      ),
                      GestureDetector(
                        onTap: _isCheckingOut ? null : _checkout,
                        child: GlassCard(
                          borderRadius: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isCheckingOut)
                                const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                                )
                              else ...[
                                const _SvgIcon('send', size: 16),
                                const SizedBox(width: 8),
                                const Text('Checkout',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ============================================================================
// BOOKINGS TAB (unchanged logic, only the surrounding scroll is now handled)
// ============================================================================
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'pending'; // 'pending', 'confirmed', 'completed'

  final Set<int> _selectedForPayment = {};

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!UserSession.isLoggedIn()) {
      setState(() {
        _isLoading = false;
        _error = 'Please login to view your bookings';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await Api.getUserBookings(UserSession.userId!);
      if (mounted) {
        setState(() {
          _allBookings = data.map((e) => BookingModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load bookings. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  List<BookingModel> get _filteredBookings {
    return _allBookings.where((b) {
      final rawStatus = b.status.trim().toLowerCase();
      return rawStatus == _selectedFilter;
    }).toList();
  }

  double get _selectedTotal {
    return _allBookings
        .where((b) => _selectedForPayment.contains(b.id))
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  void _toggleSelection(int bookingId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedForPayment.contains(bookingId)) {
        _selectedForPayment.remove(bookingId);
      } else {
        _selectedForPayment.add(bookingId);
      }
    });
  }

  void _proceedToPay() {
    if (_selectedForPayment.isEmpty) return;
    final total = _allBookings
        .where((b) => _selectedForPayment.contains(b.id))
        .fold(0.0, (sum, b) => sum + b.amount);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingPaymentBottomSheet(
        bookingIds: _selectedForPayment.toList(),
        totalAmount: total,
        onSuccess: () => _fetchBookings(),
      ),
    );
  }

  void _showChatDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _SvgIcon('chat', size: 24),
                  const SizedBox(width: 12),
                  const Text('Chat with Fixco',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const _SvgIcon('close', size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        booking.notes?.isNotEmpty == true ? booking.notes! : 'No note added',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.adminReply?.isNotEmpty == true ? booking.adminReply! : 'No reply yet',
                            style: TextStyle(
                                fontSize: 14,
                                color: booking.adminReply?.isNotEmpty == true ? Colors.white70 : Colors.white54),
                          ),
                          if (booking.replyDate != null && booking.adminReply?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text('Replied on: ${_formatDate(booking.replyDate!)}',
                                style: TextStyle(fontSize: 11, color: Colors.white38)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: GlassCard(
                    borderRadius: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _SvgIcon('close', size: 16),
                        const SizedBox(width: 8),
                        const Text('Close',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showBottomBar = _selectedFilter == 'confirmed' && _filteredBookings.isNotEmpty;
    final bool hasSelection = _selectedForPayment.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: Colors.white,
      backgroundColor: Colors.white.withOpacity(0.10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _FilterButton(
                  icon: 'pending',
                  label: 'Pending',
                  isSelected: _selectedFilter == 'pending',
                  onTap: () => setState(() {
                    _selectedFilter = 'pending';
                    _selectedForPayment.clear();
                  }),
                ),
                const SizedBox(width: 12),
                _FilterButton(
                  icon: 'confirmed',
                  label: 'Confirmed',
                  isSelected: _selectedFilter == 'confirmed',
                  onTap: () => setState(() {
                    _selectedFilter = 'confirmed';
                    _selectedForPayment.clear();
                  }),
                ),
                const SizedBox(width: 12),
                _FilterButton(
                  icon: 'completed',
                  label: 'Completed',
                  isSelected: _selectedFilter == 'completed',
                  onTap: () => setState(() {
                    _selectedFilter = 'completed';
                    _selectedForPayment.clear();
                  }),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
          if (showBottomBar)
            Padding(
              padding: EdgeInsets.only(
                  left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: !hasSelection
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_box_outline_blank_rounded, size: 18, color: Colors.white38),
                    const SizedBox(width: 8),
                    const Text('Select confirmed bookings to pay',
                        style: TextStyle(fontSize: 13, color: Colors.white54)),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${_selectedForPayment.length} service${_selectedForPayment.length > 1 ? 's' : ''} selected',
                            style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        Text('${_selectedTotal.toStringAsFixed(2)} AED',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.green)),
                      ],
                    ),
                    GestureDetector(
                      onTap: _proceedToPay,
                      child: GlassCard(
                        borderRadius: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _SvgIcon('send', size: 16),
                            const SizedBox(width: 8),
                            const Text('Proceed to Pay',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchBookings, child: const Text('Retry')),
          ],
        ),
      );
    }

    final bookings = _filteredBookings;
    if (bookings.isEmpty) {
      String message;
      switch (_selectedFilter) {
        case 'pending':
          message = 'No pending bookings';
          break;
        case 'confirmed':
          message = 'No confirmed bookings';
          break;
        case 'completed':
          message = 'No completed bookings';
          break;
        default:
          message = 'No bookings found';
      }
      return Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt_outlined, size: 48, color: Colors.white54),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Try selecting a different filter.',
                  style: TextStyle(fontSize: 13, color: Colors.white60)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isSelectable = _selectedFilter == 'confirmed';
        final isSelected = isSelectable && _selectedForPayment.contains(booking.id);
        return _FilteredBookingCard(
          booking: booking,
          isSelectable: isSelectable,
          isSelected: isSelected,
          onToggleSelect: isSelectable ? () => _toggleSelection(booking.id) : null,
          onChat: () => _showChatDialog(booking),
          onRefresh: _fetchBookings,
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red[800] : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? Colors.red[800]! : Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SvgIcon(icon, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
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
// Reusable card for filtered bookings (unchanged)
// ============================================================================
class _FilteredBookingCard extends StatefulWidget {
  final BookingModel booking;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback onChat;
  final VoidCallback onRefresh;

  const _FilteredBookingCard({
    required this.booking,
    required this.isSelectable,
    required this.isSelected,
    this.onToggleSelect,
    required this.onChat,
    required this.onRefresh,
  });

  @override
  State<_FilteredBookingCard> createState() => _FilteredBookingCardState();
}

class _FilteredBookingCardState extends State<_FilteredBookingCard> {
  bool _isCancelling = false;

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
        content: Text('Cancel "${widget.booking.serviceName}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No', style: TextStyle(color: Colors.white70))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Yes', style: TextStyle(color: Colors.red[700]))),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    final result = await Api.cancelBooking(
      bookingId: widget.booking.id,
      userId: UserSession.userId!,
      reason: 'Cancelled by user',
    );
    if (!mounted) return;
    setState(() => _isCancelling = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking cancelled'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Cancellation failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating));
    }
  }

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingReceiptDetailsBottomSheet(
        booking: widget.booking,
      ),
    );
  }

  String _getPaymentStatusLabel() {
    switch (widget.booking.paymentStatus.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return widget.booking.paymentStatus;
    }
  }

  Color _getPaymentStatusColor() {
    switch (widget.booking.paymentStatus.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.booking.status.toLowerCase() == 'pending';
    final isConfirmed = widget.booking.status.toLowerCase() == 'confirmed';
    final isCompleted = widget.booking.status.toLowerCase() == 'completed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isSelectable)
            GestureDetector(
              onTap: widget.onToggleSelect,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: widget.isSelected ? Colors.red[800] : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: widget.isSelected ? Colors.red[800]! : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: widget.isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.white.withOpacity(0.05),
                      child: CachedImageCat(
                        imageData: widget.booking.image,
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                        fallback: Icon(Icons.build_rounded, size: 36, color: Colors.white38),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.booking.serviceName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.booking.amount.toStringAsFixed(2)} AED',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.green),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getPaymentStatusLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getPaymentStatusColor(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, size: 11, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('Fixco: ${widget.booking.status}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const _SvgIcon('chat', size: 20),
                        color: Colors.white,
                        onPressed: widget.onChat,
                        tooltip: 'View note & admin reply',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 8),
                      if (isPending)
                        _isCancelling
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                          icon: const Icon(Icons.cancel_rounded, size: 24, color: Colors.white70),
                          onPressed: _cancelBooking,
                          tooltip: 'Cancel booking',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else if (isConfirmed || isCompleted)
                        IconButton(
                          icon: const Icon(Icons.receipt_long_rounded, size: 24, color: Colors.white70),
                          onPressed: _showDetails,
                          tooltip: 'View receipt & details',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}