import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/navigation/app_shell.dart';
import 'service_category_details_bottom_sheet.dart'; // contains ServiceCategoryBookingSheet

// ============================================================================
// CART MANAGER (Singleton)
// ============================================================================
class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  double get totalPrice {
    double sum = 0.0;
    for (var item in _items) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      sum += price;
    }
    return sum;
  }

  bool addItem(Map<String, dynamic> category) {
    final id = category['id'];
    if (_items.any((item) => item['id'] == id)) return false;
    _items.add(Map.from(category));
    notifyListeners();
    return true;
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// ============================================================================
// IMAGE CACHE
// ============================================================================
final Map<String, ImageProvider> _imageProviderCacheCat = {};

ImageProvider _resolveImageProviderCat(String imageData) {
  if (_imageProviderCacheCat.containsKey(imageData)) {
    return _imageProviderCacheCat[imageData]!;
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
  _imageProviderCacheCat[imageData] = provider;
  return provider;
}

class CachedImageCat extends StatelessWidget {
  final String? imageData;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallback;

  const CachedImageCat({
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
    final provider = _resolveImageProviderCat(imageData!);
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
// WAVE PAINTERS (same as GradientScaffold)
// ============================================================================
class _TopWavePainter extends CustomPainter {
  const _TopWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.45)
      ..cubicTo(
        size.width * 0.70, size.height * 0.85,
        size.width * 0.30, size.height * 0.15,
        0, size.height * 0.65,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3D0808).withOpacity(0.45)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.55)
      ..cubicTo(
        size.width * 0.65, size.height * 0.15,
        size.width * 0.35, size.height * 0.85,
        0, size.height * 0.35,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5A0C0C).withOpacity(0.40)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ============================================================================
// GLASS CARD (identical to other sheets)
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
// SVG ICONS (cart, receipt, shopping cart for bottom bar)
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

      case 'receipt':
        final receipt = Path()
          ..moveTo(6 * s, 4 * s)
          ..lineTo(6 * s, 20 * s)
          ..lineTo(9 * s, 18 * s)
          ..lineTo(12 * s, 20 * s)
          ..lineTo(15 * s, 18 * s)
          ..lineTo(18 * s, 20 * s)
          ..lineTo(18 * s, 4 * s)
          ..close()
          ..moveTo(9 * s, 9 * s)
          ..lineTo(15 * s, 9 * s)
          ..moveTo(9 * s, 13 * s)
          ..lineTo(15 * s, 13 * s);
        canvas.drawPath(receipt, paint);
        break;

      case 'shopping_cart':
        final shop = Path()
          ..moveTo(8 * s, 18 * s)
          ..cubicTo(8 * s, 19.1 * s, 8.9 * s, 20 * s, 10 * s, 20 * s)
          ..cubicTo(11.1 * s, 20 * s, 12 * s, 19.1 * s, 12 * s, 18 * s)
          ..cubicTo(12 * s, 16.9 * s, 11.1 * s, 16 * s, 10 * s, 16 * s)
          ..cubicTo(8.9 * s, 16 * s, 8 * s, 16.9 * s, 8 * s, 18 * s)
          ..close()
          ..moveTo(14 * s, 18 * s)
          ..cubicTo(14 * s, 19.1 * s, 14.9 * s, 20 * s, 16 * s, 20 * s)
          ..cubicTo(17.1 * s, 20 * s, 18 * s, 19.1 * s, 18 * s, 18 * s)
          ..cubicTo(18 * s, 16.9 * s, 17.1 * s, 16 * s, 16 * s, 16 * s)
          ..cubicTo(14.9 * s, 16 * s, 14 * s, 16.9 * s, 14 * s, 18 * s)
          ..close()
          ..moveTo(4 * s, 4 * s)
          ..lineTo(20 * s, 4 * s)
          ..lineTo(18 * s, 14 * s)
          ..lineTo(6 * s, 14 * s);
        canvas.drawPath(shop, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
}

// ============================================================================
// MAIN BOTTOM SHEET (SubServiceCategoriesBottomSheet)
// ============================================================================
class SubServiceCategoriesBottomSheet extends StatefulWidget {
  final int subServiceId;
  final String subServiceName;

  const SubServiceCategoriesBottomSheet({
    super.key,
    required this.subServiceId,
    required this.subServiceName,
  });

  @override
  State<SubServiceCategoriesBottomSheet> createState() => _SubServiceCategoriesBottomSheetState();
}

class _SubServiceCategoriesBottomSheetState extends State<SubServiceCategoriesBottomSheet> {
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    CartManager().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartManager().removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Api.getServiceCategories(subServiceId: widget.subServiceId);
      if (mounted) {
        setState(() {
          _categories = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load categories. Please try again.';
          _loading = false;
        });
      }
    }
  }

  void _showCategoryDetails(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceCategoryBookingSheet(category: category),
    );
  }

  void _addToCart(Map<String, dynamic> category) {
    final cart = CartManager();
    final added = cart.addItem(category);
    if (added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${category['name']}" to cart'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item already in cart'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _viewCart() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (appShellKey.currentContext != null) {
      appShellKey.currentState?.setTab(2);
    } else {
      debugPrint('AppShell key not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.50, 1.0],
      colors: [
        Color(0xFF1C0404),
        Color(0xFF6B1010),
        Color(0xFF1C0404),
      ],
    );

    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.25, 0.5, 0.75, 1.0],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.22,
                child: const CustomPaint(painter: _TopWavePainter()),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.22,
                child: const CustomPaint(painter: _BottomWavePainter()),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.subServiceName} Categories',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildContent(scrollController),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final cart = CartManager();
    final count = cart.itemCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 30,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _SvgIcon('shopping_cart', size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$count item${count != 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: count > 0 ? _viewCart : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: count > 0 ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'View Cart',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 48, color: Colors.white38),
            SizedBox(height: 12),
            Text(
              'No categories available\nfor this sub‑service.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    final cartItems = CartManager().items;
    final Set<int> cartItemIds = cartItems.map((e) => e['id'] as int).toSet();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final name = cat['name']?.toString() ?? 'Category';
        final image = cat['image']?.toString() ?? '';
        final description = cat['description']?.toString() ?? '';
        final double price = double.tryParse(cat['price']?.toString() ?? '0') ?? 0.0;
        final double rating = double.tryParse(cat['rating']?.toString() ?? '0') ?? 0.0;
        final expectedTime = cat['expected_time']?.toString() ?? '';
        final bool isInCart = cartItemIds.contains(cat['id']);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CachedImageCat(
                      imageData: image,
                      fit: BoxFit.cover,
                      fallback: const Icon(Icons.category_outlined, size: 40, color: Colors.white38),
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
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (price > 0)
                            Text(
                              '${price.toStringAsFixed(0)} AED',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green),
                            ),
                          if (expectedTime.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.white70),
                                const SizedBox(width: 2),
                                Text(
                                  expectedTime,
                                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: isInCart ? null : () => _addToCart(cat),
                              child: GlassCard(
                                borderRadius: 8,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _SvgIcon('cart', size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      isInCart ? 'In Cart' : 'Cart',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showCategoryDetails(cat),
                              child: GlassCard(
                                borderRadius: 8,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const _SvgIcon('receipt', size: 14),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Details',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}