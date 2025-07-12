import 'dart:convert';

import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:evetcare_admin/core/config.dart';
import 'package:evetcare_admin/models/appointment.dart';
import 'package:evetcare_admin/models/genders.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/species.dart';
import 'package:evetcare_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:evetcare_admin/utils/logging.dart';

class PatientProvider extends BaseProvider<Patient> {
  PatientProvider() : super("/Pets");

  @override
  Patient fromJson(data) {
    return Patient.fromJson(data);
  }

  Future<List<Appointment>> getAppointmentsForPatient(int petId) async {
    ApiLogger.logRequest(
      method: 'GET',
      url: '$baseUrl/Appointments?PetId=$petId',
      headers: createHeaders(),
    );
    final response = await http.get(
      Uri.parse('$baseUrl/Appointments?PetId=$petId'),
      headers: createHeaders(),
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: '$baseUrl/Appointments?PetId=$petId',
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data["result"];

      final appointments = results
          .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
          .toList();
      return appointments;
    } else {
      throw Exception("Failed to load appointments: ${response.statusCode}");
    }
  }

  Future<void> updateAppointmentStatus(int appointmentId, String action) async {
    final uri = Uri.parse('$baseUrl/Appointments/$appointmentId/$action');
    ApiLogger.logRequest(
      method: 'PUT',
      url: '$baseUrl/Appointments/$appointmentId/$action',
      headers: createHeaders(),
    );
    final response = await http.put(uri, headers: createHeaders());
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
    } else {
      throw Exception("Failed to update status: ${response.body}");
    }
  }

  Future<List<Species>> getSpecies() async {
    ApiLogger.logRequest(
      method: 'GET',
      url: '$baseUrl/Species',
      headers: createHeaders(),
    );
    final response = await http.get(
      Uri.parse('$baseUrl/Species'),
      headers: createHeaders(),
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: '$baseUrl/Species',
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> result = data['result'];
      return result.map((json) => Species.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load species');
    }
  }

  Future<List<Gender>> getGenders() async {
    ApiLogger.logRequest(
      method: 'GET',
      url: '$baseUrl/Gender',
      headers: createHeaders(),
    );
    final response = await http.get(
      Uri.parse('$baseUrl/Gender'),
      headers: createHeaders(),
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: '$baseUrl/Gender',
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> result = data['result'];
      return result.map((json) => Gender.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load genders');
    }
  }
}
