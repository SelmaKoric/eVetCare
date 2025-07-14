import 'package:evetcare_admin/models/service.dart';
import 'package:evetcare_admin/providers/base_provider.dart';
import 'package:evetcare_admin/models/service_category.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/authorization.dart';

class ServiceProvider extends BaseProvider<Service> {
  ServiceProvider() : super("/Services");

  @override
  Service fromJson(data) {
    return Service.fromJson(data);
  }

  Future<List<ServiceCategory>> getServiceCategories() async {
    final token = Authorization.token;
    final response = await http.get(
      Uri.parse('http://localhost:5081/ServiceCategory'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );
    print(
      'ServiceCategory status: ${response.statusCode}, body: ${response.body}',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> result = data['result'];
      return result.map((json) => ServiceCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load service categories');
    }
  }
}
