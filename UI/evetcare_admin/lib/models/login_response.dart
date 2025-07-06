import 'dart:convert';

import 'package:evetcare_admin/core/config.dart';
import 'package:http/http.dart' as http;

class LoginResponse {
  final String token;
  final String fullName;
  final String role;

  LoginResponse({
    required this.token,
    required this.fullName,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      fullName: json['fullName'],
      role: json['role'],
    );
  }

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
    final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

    return loginResponse;
  } else {
    throw Exception("Login failed: ${response.body}");
  }
}
}