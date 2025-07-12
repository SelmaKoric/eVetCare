import 'dart:convert';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/search_result.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../utils/logging.dart';

class PatientService {
  static Future<SearchResult<Patient>> getPatients({
    String? name,
    int page = 1,
  }) async {
    final uri = Uri.parse('$patientsEndpoint?Name=${name ?? ""}&Page=$page');

    ApiLogger.logRequest(
      method: 'GET',
      url: '$patientsEndpoint?Name=${name ?? ""}&Page=$page',
      headers: {"Content-Type": "application/json"},
    );
    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return SearchResult<Patient>.fromJson(
        json,
        (data) => Patient.fromJson(data),
      );
    } else {
      throw Exception("Failed to load patients: ${response.body}");
    }
  }
}
