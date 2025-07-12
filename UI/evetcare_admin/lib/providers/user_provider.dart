import 'dart:convert';
import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:evetcare_admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:evetcare_admin/utils/logging.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class UserProvider extends ChangeNotifier {
  Future<List<User>> getAllOwners() async {
    ApiLogger.logRequest(
      method: 'GET',
      url: '$baseUrl/User',
      headers: createHeaders(),
    );
    final response = await http.get(
      Uri.parse('$baseUrl/User'),
      headers: createHeaders(),
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: '$baseUrl/User',
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> result = data['result'];

      return result.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load owners: ${response.statusCode}');
    }
  }
}

String get baseUrl {
  if (kIsWeb) {
    return "http://localhost:5081";
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return "http://10.0.2.2:5081";
  }
  return "http://localhost:5081";
}

final loginEndpoint = "$baseUrl/api/Auth/login";
final patientsEndpoint = "$baseUrl/Pets";
