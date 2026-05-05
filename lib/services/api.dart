import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = 'http://admin.medco-contracting.com/api';

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/get_user_profile.php?user_id=$userId');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> registerUser(
      String fullName,
      String email,
      String phone,
      String password,
      ) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/register_user.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      String email,
      String password,
      ) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/login_user.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  static Future<void> saveFCMToken(int userId, String token) async {
    final url = Uri.parse('https://admin.medco-contracting.com/api/save_fcm_token.php');

    await http.post(
      url,
      body: {
        'user_id': userId.toString(),
        'fcm_token': token,
      },
    );
  }

  static Future<List<dynamic>> getServices() async {
    try {
      final url = Uri.parse('$baseUrl/get_services.php');

      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['services'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getProjects() async {
    try {
      final url = Uri.parse('$baseUrl/get_projects.php');

      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['projects'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getUserBookings(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/get_user_bookings.php?user_id=$userId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['bookings'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int serviceId,
    required String bookingDate,
    required String bookingTime,
    String notes = '',
  }) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/add_booking.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'service_id': serviceId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }

  static Future<void> cancelBooking(int bookingId) async {
    final url = Uri.parse('https://admin.medco-contracting.com/api/cancel_booking.php');

    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'booking_id': bookingId}),
    );
  }

  static Future<Map<String, dynamic>> sendContact(
      String name,
      String email,
      String phone,
      String message,
      ) async {
    try {
      final url = Uri.parse('https://admin.medco-contracting.com/api/send_contact.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error (${response.statusCode})'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error. Please try again.'};
    }
  }
}