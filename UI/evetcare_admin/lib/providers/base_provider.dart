import 'dart:convert';
import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/search_result.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  String endpoint;

  BaseProvider(this.endpoint);

  Future<SearchResult<T>> get({Map<String, dynamic>? filter}) async {
    String url = "$baseUrl$endpoint";

    if (filter != null && filter.isNotEmpty) {
      final query = Uri(
        queryParameters: filter.map((k, v) => MapEntry(k, v.toString())),
      ).query;
      url = "$url?$query";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: createHeaders(), 
    );

    if (response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return SearchResult<T>.fromJson(data, fromJson);
    } else {
      throw Exception("Failed: ${response.statusCode} ${response.body}");
    }
  }

  T fromJson(dynamic json);
}
