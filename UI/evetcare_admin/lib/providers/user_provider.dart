import 'dart:convert';
import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:evetcare_admin/core/config.dart';
import 'package:evetcare_admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  Future<List<User>> getAllOwners() async {
    final response = await http.get(
      Uri.parse('$baseUrl/User'), 
      headers: createHeaders(),
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
