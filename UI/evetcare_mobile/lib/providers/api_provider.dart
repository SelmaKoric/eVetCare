import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/authorization.dart';

class ApiProvider {
  static const String baseUrl = 'http://10.0.2.2:5081';

  // Headers for authenticated requests
  static Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer ${Authorization.token}',
    'Content-Type': 'application/json',
  };

  // Generic HTTP methods
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _authHeaders,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
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
    final response = await get(
      '/MedicalRecord?PetId=$petId&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true',
    );

    if (response is Map && response.containsKey('result')) {
      final result = response['result'];
      if (result is List) {
        return List<Map<String, dynamic>>.from(result);
      }
    } else if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }

    return [];
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
