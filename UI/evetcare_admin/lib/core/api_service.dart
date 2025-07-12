import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import 'config.dart';
import '../utils/logging.dart';

class ApiService {
  static Future<LoginResponse?> login(String email, String password) async {
    ApiLogger.logRequest(
      method: 'POST',
      url: loginEndpoint,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": email, "password": password}),
    );
    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": email, "password": password}),
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: loginEndpoint,
      body: response.body,
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }
}
