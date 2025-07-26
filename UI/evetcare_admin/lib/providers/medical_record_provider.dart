import 'dart:convert';
import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:evetcare_admin/core/config.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:http/http.dart' as http;
import 'package:evetcare_admin/utils/logging.dart';

class MedicalRecordProvider {
  Future<List<MedicalRecord>> getMedicalRecordsByPetName(String petName) async {
    final uri = Uri.parse(
      '$baseUrl/MedicalRecord?PetName=$petName&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true',
    );
    ApiLogger.logRequest(
      method: 'GET',
      url:
          '$baseUrl/MedicalRecord?PetName=$petName&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true',
      headers: createHeaders(),
    );
    final response = await http.get(uri, headers: createHeaders());
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> result = data['result'];

      for (int i = 0; i < result.length; i++) {
        final record = result[i];

        if (record['diagnoses'] != null) {
          for (int j = 0; j < record['diagnoses'].length; j++) {
            final diagnosis = record['diagnoses'][j];
            print('    Diagnosis $j: ${diagnosis['description']}');
          }
        }
      }

      return result.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medical history');
    }
  }

  Future<List<MedicalRecord>> getMedicalRecordsByPetId(int petId) async {
    final uri = Uri.parse(
      '$baseUrl/MedicalRecord?PetId=$petId&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true',
    );
    ApiLogger.logRequest(
      method: 'GET',
      url:
          '$baseUrl/MedicalRecord?PetId=$petId&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true',
      headers: createHeaders(),
    );
    final response = await http.get(uri, headers: createHeaders());
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> result = data['result'];
      return result.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medical history');
    }
  }
}
