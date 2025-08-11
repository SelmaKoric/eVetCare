import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/authorization.dart';
import '../core/config.dart' as config;

class ApiProvider {
  static String get baseUrl => config.baseUrl;

  // Headers for authenticated requests
  static Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer ${Authorization.token}',
    'Content-Type': 'application/json',
  };

  // Generic HTTP methods
  static Future<dynamic> get(String endpoint) async {
    print('ApiProvider: Making GET request to: $baseUrl$endpoint');
    print('ApiProvider: Headers: $_authHeaders');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      print('ApiProvider: Response status: ${response.statusCode}');
      print('ApiProvider: Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('ApiProvider: HTTP request failed: $e');
      rethrow;
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _authHeaders,
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<dynamic> put(
    String endpoint, [
    Map<String, dynamic>? data,
  ]) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _authHeaders,
      body: data != null ? json.encode(data) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<void> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _authHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Specific API methods
  static Future<List<Map<String, dynamic>>> getPets() async {
    final response = await get('/Pets?OwnerId=${Authorization.userId}');

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map && response.containsKey('result')) {
      final result = response['result'];
      if (result is List) {
        return List<Map<String, dynamic>>.from(result);
      }
    }

    return [];
  }

  static Future<List<Map<String, dynamic>>> getMedicalRecords(int petId) async {
    print('ApiProvider: Getting medical records for pet ID: $petId');
    print('ApiProvider: Base URL: $baseUrl');
    print('ApiProvider: Authorization token: ${Authorization.token}');
    print('ApiProvider: Authorization userId: ${Authorization.userId}');

    try {
      final endpoint =
          '/MedicalRecord?PetId=$petId&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true';
      print('ApiProvider: Full URL: $baseUrl$endpoint');

      final response = await get(endpoint);

      print('ApiProvider: Raw response type: ${response.runtimeType}');
      print('ApiProvider: Raw response: $response');

      if (response is Map && response.containsKey('result')) {
        final result = response['result'];
        print('ApiProvider: Found result key, type: ${result.runtimeType}');
        if (result is List) {
          print('ApiProvider: Returning ${result.length} records from result');
          return List<Map<String, dynamic>>.from(result);
        }
      } else if (response is List) {
        print(
          'ApiProvider: Response is List, returning ${response.length} records',
        );
        return List<Map<String, dynamic>>.from(response);
      }

      print('ApiProvider: No valid data found, returning empty list');
      return [];
    } catch (e) {
      print('ApiProvider: Error getting medical records: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await get(
      '/Notification/user/${Authorization.userId}/unread',
    );

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return [];
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    await put('/Notification/$notificationId/mark-as-read');
  }

  static Future<void> cancelAppointment(int appointmentId) async {
    await put('/Appointments/$appointmentId/cancel');
  }

  static Future<Map<String, dynamic>> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    return await post('/Appointments', appointmentData);
  }

  static Future<Map<String, dynamic>> createInvoice(
    Map<String, dynamic> invoiceData,
  ) async {
    return await post('/Invoice', invoiceData);
  }

  static Future<Map<String, dynamic>> createPayment(
    Map<String, dynamic> paymentData,
  ) async {
    return await post('/Payments', paymentData);
  }

  static Future<Map<String, dynamic>> addPet(
    Map<String, dynamic> petData,
  ) async {
    return await post('/Pets', petData);
  }
}
