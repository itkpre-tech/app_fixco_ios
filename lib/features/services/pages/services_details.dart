import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fixco/services/api.dart';
import 'package:fixco/features/authentication/login/pages/login.dart';
import 'package:fixco/services/user_session.dart';

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
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

class ServiceDetails extends StatefulWidget {
  final String serviceId;

  const ServiceDetails({super.key, required this.serviceId});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  Map<String, dynamic>? _service;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final services = await Api.getServices();
      final found = services.firstWhere(
            (s) => s['id'].toString() == widget.serviceId,
        orElse: () => null,
      );
      if (mounted) {
        setState(() {
          _service = found;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showBookingDialog() async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final TextEditingController notesController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Book Service',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                    ),
                    title: Text(
                      selectedDate.toLocal().toString().split(' ')[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.access_time,
                      color: Colors.white70,
                    ),
                    title: Text(
                      selectedTime.format(context),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Additional notes (optional)',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _submitBooking(
                date: selectedDate,
                time: selectedTime,
                notes: notesController.text.trim(),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBooking({
    required DateTime date,
    required TimeOfDay time,
    required String notes,
  }) async {
    final bookingDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final bookingTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await Api.createBooking(
      userId: UserSession.userId!,
      serviceId: int.parse(_service!['id'].toString()),
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      notes: notes,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to create booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onBookNow() {
    if (!UserSession.isLoggedIn()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Login Required',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please log in to book this service.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }

    _showBookingDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchServiceDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _service == null
          ? const Center(
        child: Text(
          'Service not found',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              width: double.infinity,
              child: CachedImage(
                imageData: _service!['image'] ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 280,
                fallback: Container(
                  color: Colors.grey[850],
                  child: const Icon(
                    Icons.build_rounded,
                    color: Colors.white38,
                    size: 64,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _service!['name'] ?? 'Service',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AED ${_service!['price'] ?? '0'}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _service!['description'] ??
                        'No description available.',
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onBookNow,
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}