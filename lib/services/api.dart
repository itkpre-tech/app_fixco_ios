import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// ─── API service — single file for iOS + Android ─────────────────────────────
class Api {
  static const String baseUrl = 'http://admin.medco-contracting.com/api';

  // ─── User profile ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/get_user_profile.php?user_id=$userId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please check your internet.'};
    }
  }

  // ─── Auth — register ───────────────────────────────────────────────────────
  // Android version used named params + extra fields (role, emirate, location)
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? emirate,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/register_user.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name':  fullName,
          'email':      email,
          'phone':      phone,
          'password':   password,
          'user_role':  role,
          'emirate':    emirate,
          'address':    address ?? '',
          'latitude':   latitude,
          'longitude':  longitude,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  // ─── Auth — login ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> loginUser(
      String email,
      String password,
      ) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/login_user.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  // ─── Auth — forgot password ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/forgot_password.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) return json.decode(response.body);
      // Endpoint may not exist yet — return safe UX message
      return {
        'status':  'success',
        'message': 'If this email is registered, you will receive a password reset link.',
      };
    } catch (_) {
      // Don't leak system errors to the user
      return {
        'status':  'success',
        'message': 'If this email is registered, you will receive a password reset link.',
      };
    }
  }

  // ─── Auth — reset password ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/reset_password.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token, 'new_password': newPassword}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  // ─── FCM token ─────────────────────────────────────────────────────────────
  static Future<void> saveFCMToken(int userId, String token) async {
    final url = Uri.parse('https://admin.medco-contracting.com/api/save_fcm_token.php');
    await http.post(
      url,
      body: {'user_id': userId.toString(), 'fcm_token': token},
    );
  }

  // ─── Services — main categories ────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final url      = Uri.parse('$baseUrl/get_services.php');
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['services'] != null) {
          return List<Map<String, dynamic>>.from(data['services'] as List);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return [];
    }
  }

  // ─── Services — sub-services ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getSubServices({int? serviceId}) async {
    try {
      final uri = (serviceId != null && serviceId > 0)
          ? Uri.parse('$baseUrl/get_sub_services.php?service_id=$serviceId')
          : Uri.parse('$baseUrl/get_sub_services.php');

      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['sub_services'] is List) {
          return List<Map<String, dynamic>>.from(data['sub_services'] as List);
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching sub-services: $e');
      return [];
    }
  }

  // ─── Services — categories with optional filters ───────────────────────────
  static Future<List<Map<String, dynamic>>> getServiceCategories({
    int? serviceId,
    int? subServiceId,
  }) async {
    try {
      // Build query string from whichever filters are provided
      final params = <String, String>{};
      if (serviceId    != null && serviceId    > 0) params['service_id']     = '$serviceId';
      if (subServiceId != null && subServiceId > 0) params['sub_service_id'] = '$subServiceId';

      final uri = Uri.parse('$baseUrl/get_service_categories.php')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['categories'] is List) {
          return List<Map<String, dynamic>>.from(data['categories'] as List);
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching service categories: $e');
      return [];
    }
  }

  // ─── Projects ──────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getProjects() async {
    try {
      final url      = Uri.parse('$baseUrl/get_projects.php');
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['projects'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Certificates ──────────────────────────────────────────────────────────
  static Future<List<dynamic>> getCertificates() async {
    try {
      final url      = Uri.parse('$baseUrl/get_certificates.php');
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success') return data['certificates'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Offers ────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getOffers() async {
    try {
      final url = Uri.parse('$baseUrl/get_offers.php');
      debugPrint('📦 Fetching offers from: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 20));
      debugPrint('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'success' && data['offers'] is List) {
          final List offers = data['offers'] as List;
          debugPrint('✅ Found ${offers.length} offers');

          // Normalise each offer into a typed map
          return offers.map<Map<String, dynamic>>((o) => {
            'id':          o['id'],
            'title':       o['title']       ?? '',
            'description': o['description'] ?? '',
            'image':       o['image']        ?? '',
            'is_active':   o['is_active']   ?? 1,
          }).toList();
        }

        debugPrint('❌ API returned error status or empty offers');
        return [];
      }

      debugPrint('❌ HTTP Error: ${response.statusCode}');
      return [];
    } catch (e, st) {
      debugPrint('❌ Exception fetching offers: $e\n$st');
      return [];
    }
  }

  // ─── Bookings — list ───────────────────────────────────────────────────────
  static Future<List<dynamic>> getUserBookings(int userId) async {
    try {
      final url      = Uri.parse('$baseUrl/get_user_bookings.php?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['bookings'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Bookings — create ─────────────────────────────────────────────────────
  // Supports optional sub-service and category fields for the Android flow
  static Future<Map<String, dynamic>> createBooking({
    required int    userId,
    required int    serviceId,
    int?            subServiceId,
    int?            subServiceCategoryId,
    required String bookingDate,
    required String bookingTime,
    String?         notes,
    String?         paymentMethod, // 'cash' | 'card' | null
  }) async {
    try {
      final url  = Uri.parse('https://admin.medco-contracting.com/api/add_booking.php');
      final body = <String, dynamic>{
        'user_id':      userId,
        'service_id':   serviceId,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
      };

      // Only include optional fields when they carry a real value
      if (subServiceId         != null) body['sub_service_id']          = subServiceId;
      if (subServiceCategoryId != null) body['sub_service_category_id'] = subServiceCategoryId;
      if (notes != null && notes.isNotEmpty) body['notes']              = notes;
      if (paymentMethod        != null) body['payment_method']          = paymentMethod;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  // ─── Bookings — cancel ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> cancelBooking({
    required int    bookingId,
    required int    userId,
    String          reason = 'Cancelled by user',
  }) async {
    try {
      final url      = Uri.parse('https://admin.medco-contracting.com/api/cancel_booking.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'booking_id': bookingId,
          'user_id':    userId,
          'reason':     reason,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  // ─── Payments — process multiple bookings at once ──────────────────────────
  static Future<Map<String, dynamic>> processPayments({
    required int         userId,
    required List<int>   bookingIds,
    required String      paymentMethod,
    String?              transactionId,
  }) async {
    try {
      final url  = Uri.parse('https://admin.medco-contracting.com/api/add_payment.php');
      final body = <String, dynamic>{
        'user_id':        userId,
        'bookings':       bookingIds,
        'payment_method': paymentMethod,
      };
      if (transactionId != null && transactionId.isNotEmpty) {
        body['transaction_id'] = transactionId;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  // ─── Contact form ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendContact(
      String name,
      String email,
      String phone,
      String message,
      ) async {
    try {
      final url      = Uri.parse('https://admin.medco-contracting.com/api/send_contact.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name':    name,
          'email':   email,
          'phone':   phone,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }
}
