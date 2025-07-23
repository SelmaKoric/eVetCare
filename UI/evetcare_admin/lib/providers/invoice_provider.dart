import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';
import '../models/search_result.dart';
import '../utils/authorization.dart';

class InvoiceProvider extends ChangeNotifier {
  Future<SearchResult<Invoice>> get({Map<String, dynamic>? filter}) async {
    final uri = Uri.parse('http://localhost:5081/Invoice').replace(
      queryParameters: filter?.map((k, v) => MapEntry(k, v.toString())),
    );
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
      if (Authorization.token != null)
        'Authorization': 'Bearer ${Authorization.token}',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return SearchResult<Invoice>.fromJson(
        data,
        (json) => Invoice.fromJson(json as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to load invoices: \n${response.body}');
    }
  }
}
