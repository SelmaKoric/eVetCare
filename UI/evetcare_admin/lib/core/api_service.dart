import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import 'config.dart';

class ApiService {
  static Future<LoginResponse?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }
}