import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../gradient_scaffold.dart';

// ============================================================================
// GLASS CARD – identical to login/register screens
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
// REGISTER LOCATION SCREEN – glass design
// ============================================================================
class RegisterLocationScreen extends StatefulWidget {
  final String selectedEmirate;
  const RegisterLocationScreen({super.key, required this.selectedEmirate});

  @override
  State<RegisterLocationScreen> createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(25.2048, 55.2708);
  LatLng _pickedPosition = const LatLng(25.2048, 55.2708);
  String? _selectedAddress;
  bool _isLoadingLocation = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final LatLngBounds _emirateBounds;

  @override
  void initState() {
    super.initState();
    _setEmirateBounds();
    _getCurrentLocation();
  }

  void _setEmirateBounds() {
    switch (widget.selectedEmirate.toLowerCase()) {
      case 'dubai':
        _emirateBounds = LatLngBounds(
          southwest: const LatLng(24.8, 54.9),
          northeast: const LatLng(25.5, 55.6),
        );
        _currentPosition = const LatLng(25.2048, 55.2708);
        _pickedPosition = _currentPosition;
        break;
      case 'sharjah':
        _emirateBounds = LatLngBounds(
          southwest: const LatLng(25.2, 55.3),
          northeast: const LatLng(25.5, 55.6),
        );
        _currentPosition = const LatLng(25.3573, 55.3919);
        _pickedPosition = _currentPosition;
        break;
      case 'ajman':
        _emirateBounds = LatLngBounds(
          southwest: const LatLng(25.38, 55.41),
          northeast: const LatLng(25.44, 55.46),
        );
        _currentPosition = const LatLng(25.4111, 55.4353);
        _pickedPosition = _currentPosition;
        break;
      default:
        _emirateBounds = LatLngBounds(
          southwest: const LatLng(24.8, 54.9),
          northeast: const LatLng(25.5, 55.6),
        );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      LatLng userPos = LatLng(position.latitude, position.longitude);
      if (_isWithinBounds(userPos)) {
        setState(() {
          _currentPosition = userPos;
          _pickedPosition = _currentPosition;
        });
        await _updateAddressFromCoordinates(_pickedPosition);
        await _moveCamera(_pickedPosition);
      } else {
        await _updateAddressFromCoordinates(_pickedPosition);
        await _moveCamera(_pickedPosition);
        _showSnackBar(
            'Your location is outside ${widget.selectedEmirate}. Using default location.');
      }
    } catch (e) {
      debugPrint('Location error: $e');
      await _updateAddressFromCoordinates(_pickedPosition);
      await _moveCamera(_pickedPosition);
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  bool _isWithinBounds(LatLng point) {
    return point.latitude >= _emirateBounds.southwest.latitude &&
        point.latitude <= _emirateBounds.northeast.latitude &&
        point.longitude >= _emirateBounds.southwest.longitude &&
        point.longitude <= _emirateBounds.northeast.longitude;
  }

  Future<void> _showLocationServiceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Location Services Disabled',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Please enable location services to pick your location.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == true) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Location Permission Denied',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Cannot get your current location. You can still search for a location manually.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _moveCamera(LatLng target) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(target, 14),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCamera(_pickedPosition);
  }

  void _onCameraMove(CameraPosition position) {
    if (_isWithinBounds(position.target)) {
      _pickedPosition = position.target;
    } else {
      _moveCamera(_pickedPosition);
    }
  }

  void _onCameraIdle() {
    _updateAddressFromCoordinates(_pickedPosition);
  }

  Future<void> _updateAddressFromCoordinates(LatLng position) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'];
        if (mounted) {
          setState(() {
            _selectedAddress = address;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedAddress = '${position.latitude}, ${position.longitude}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress = '${position.latitude}, ${position.longitude}';
        });
      }
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showSnackBar('Please enter a location');
      return;
    }

    setState(() => _isLoadingLocation = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);
          final newPos = LatLng(lat, lon);
          if (_isWithinBounds(newPos)) {
            setState(() {
              _pickedPosition = newPos;
            });
            await _moveCamera(newPos);
            await _updateAddressFromCoordinates(newPos);
          } else {
            _showSnackBar('Location is outside ${widget.selectedEmirate}.');
          }
        } else {
          _showSnackBar('Location not found');
        }
      } else {
        _showSnackBar('Search failed');
      }
    } catch (e) {
      _showSnackBar('Error searching location');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _confirmLocation() {
    if (_selectedAddress == null || _selectedAddress!.isEmpty) {
      _showSnackBar('Please wait while we fetch address...');
      return;
    }
    Navigator.pop(context, {
      'latitude': _pickedPosition.latitude,
      'longitude': _pickedPosition.longitude,
      'address': _selectedAddress,
    });
  }

  void _skipLocation() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchBar(),
          Expanded(
            child: _buildMapView(),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pick Location (${widget.selectedEmirate.toUpperCase()})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search within ${widget.selectedEmirate}...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withOpacity(0.55), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GlassCard(
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            onTap: _searchLocation,
            child: const Text(
              'Go',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            cameraTargetBounds: CameraTargetBounds(_emirateBounds),
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            markers: const {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            minMaxZoomPreference: const MinMaxZoomPreference(10, 16),
          ),
          const IgnorePointer(
            child: Center(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 48,
              ),
            ),
          ),
          if (_isLoadingLocation)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedAddress != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Text(
                _selectedAddress!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: _skipLocation,
                  child: const Center(
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: _confirmLocation,
                  child: const Center(
                    child: Text(
                      'Confirm Location',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}