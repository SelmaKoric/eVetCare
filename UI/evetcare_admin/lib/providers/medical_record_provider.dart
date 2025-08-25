import 'dart:convert';
import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:evetcare_admin/core/config.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/models/lab_test.dart';
import 'package:http/http.dart' as http;
import 'package:evetcare_admin/utils/logging.dart';

class MedicalRecordProvider {
  Future<MedicalRecord> createMedicalRecord({
    required int petId,
    required int appointmentId,
    required String date,
    required String notes,
    required String analysisProvided,
  }) async {
    final uri = Uri.parse('$baseUrl/MedicalRecord');

    final requestBody = {
      'petId': petId,
      'appointmentId': appointmentId,
      'date': date,
      'notes': notes,
      'analysisProvided': analysisProvided,
    };

    ApiLogger.logRequest(
      method: 'POST',
      url: '$baseUrl/MedicalRecord',
      headers: createHeaders(),
      body: jsonEncode(requestBody),
    );

    final response = await http.post(
      uri,
      headers: {...createHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return MedicalRecord.fromJson(data);
    } else {
      throw Exception('Failed to create medical record: ${response.body}');
    }
  }

  Future<MedicalRecord> updateMedicalRecord({
    required int medicalRecordId,
    required int petId,
    required int appointmentId,
    required String date,
    required String notes,
    required String analysisProvided,
  }) async {
    final uri = Uri.parse('$baseUrl/MedicalRecord/$medicalRecordId');

    final requestBody = {
      'petId': petId,
      'appointmentId': appointmentId,
      'date': date,
      'notes': notes,
      'analysisProvided': analysisProvided,
    };

    ApiLogger.logRequest(
      method: 'PUT',
      url: '$baseUrl/MedicalRecord/$medicalRecordId',
      headers: createHeaders(),
      body: jsonEncode(requestBody),
    );

    final response = await http.put(
      uri,
      headers: {...createHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.statusCode == 204) {
        print('⚠️ Server returned 204 (No Content) for update');
        return MedicalRecord(
          medicalRecordId: medicalRecordId,
          petId: petId,
          appointmentId: appointmentId,
          date: DateTime.parse(date),
          notes: notes,
          analysisProvided: analysisProvided,
          petName: null, 
          diagnoses: [],
          treatments: [],
          labResults: [],
          vaccinations: [],
        );
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MedicalRecord.fromJson(data);
      }
    } else {
      throw Exception('Failed to update medical record: ${response.body}');
    }
  }

  Future<void> createTreatment({
    required int medicalRecordId,
    required String treatmentDescription,
  }) async {
    final uri = Uri.parse('$baseUrl/Treatment');

    final requestBody = {
      'medicalRecordId': medicalRecordId,
      'treatmentDescription': treatmentDescription,
    };

    print('=== TREATMENT API CALL ===');
    print('URL: $baseUrl/Treatment');
    print('Request Body: ${jsonEncode(requestBody)}');

    ApiLogger.logRequest(
      method: 'POST',
      url: '$baseUrl/Treatment',
      headers: createHeaders(),
      body: jsonEncode(requestBody),
    );

    final response = await http.post(
      uri,
      headers: {...createHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create treatment: ${response.body}');
    }
  }

  Future<void> createLabResult({
    required int medicalRecordId,
    required int labTestId,
    required String resultValue,
    String? testName,
  }) async {
    final uri = Uri.parse('$baseUrl/LabResult');

    final requestBody = {
      'medicalRecordId': medicalRecordId,
      'labTestId': labTestId,
      'resultValue': resultValue,
      if (testName != null) 'testName': testName,
    };

    print('=== LAB RESULT API CALL ===');
    print('URL: $baseUrl/LabResult');
    print('Request Body: ${jsonEncode(requestBody)}');

    ApiLogger.logRequest(
      method: 'POST',
      url: '$baseUrl/LabResult',
      headers: createHeaders(),
      body: jsonEncode(requestBody),
    );

    final response = await http.post(
      uri,
      headers: {...createHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create lab result: ${response.body}');
    }
  }

  Future<void> createDiagnosis({
    required int medicalRecordId,
    required String description,
  }) async {
    final uri = Uri.parse('$baseUrl/Diagnoses');

    final requestBody = {
      'medicalRecordId': medicalRecordId,
      'description': description,
    };

    print('=== DIAGNOSIS API CALL ===');
    print('URL: $baseUrl/Diagnoses');
    print('Request Body: ${jsonEncode(requestBody)}');

    ApiLogger.logRequest(
      method: 'POST',
      url: '$baseUrl/Diagnoses',
      headers: createHeaders(),
      body: jsonEncode(requestBody),
    );

    final response = await http.post(
      uri,
      headers: {...createHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create diagnosis: ${response.body}');
    }
  }

  Future<void> createVaccination({
    required int medicalRecordId,
    required String name,
    required DateTime dateGiven,
    required DateTime nextDue,
  }) async {
    final uri = Uri.parse('$baseUrl/Vaccination');

    final requestBody = {
      'medicalRecordId': medicalRecordId,
      'name': name,
      'dateGiven': dateGiven.toIso8601String(),
      'nextDue': nextDue.toIso8601String(),
    };

    print('=== VACCINATION API CALL ===');
    print('URL: $baseUrl/Vaccination');
    print('Request Body: ${jsonEncode(requestBody)}');

    ApiLogger.logRequest(
      method: 'POST',
      url: '$baseUrl/Vaccination',
      headers: createHeaders(),
      body: jsonEncode(requestBody),
    );

    final response = await http.post(
      uri,
      headers: {...createHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create vaccination: ${response.body}');
    }
  }

  Future<List<LabTest>> getLabTests() async {
    final uri = Uri.parse('$baseUrl/LabTest');

    ApiLogger.logRequest(
      method: 'GET',
      url: '$baseUrl/LabTest',
      headers: createHeaders(),
    );

    final response = await http.get(uri, headers: createHeaders());

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('LabTest API Response: $responseData');

      // Extract the result array from the paginated response
      final List<dynamic> resultList = responseData['result'] ?? [];
      print('LabTest result array: $resultList');
      print('LabTest count: ${resultList.length}');

      final labTests = resultList.map((json) {
        print('Parsing lab test: $json');
        return LabTest.fromJson(json);
      }).toList();

      print(
        'Parsed lab tests: ${labTests.map((lt) => '${lt.labTestId}: ${lt.name}').join(', ')}',
      );
      return labTests;
    } else {
      print('LabTest API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load lab tests: ${response.body}');
    }
  }

  Future<List<MedicalRecord>> getMedicalRecordsByPetId(int petId) async {
    final uri = Uri.parse(
      '$baseUrl/MedicalRecord?PetId=$petId&IncludeDiagnoses=true&IncludeTreatments=true&IncludeLabResults=true&IncludeVaccinations=true',
    );

    ApiLogger.logRequest(
      method: 'GET',
      url: uri.toString(),
      headers: createHeaders(),
    );

    final response = await http.get(uri, headers: createHeaders());

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: uri.toString(),
      body: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('MedicalRecord API Response: $responseData');

      final List<dynamic> resultList = responseData['result'] ?? [];
      print('MedicalRecord result array: $resultList');
      print('MedicalRecord count: ${resultList.length}');

      final medicalRecords = resultList.map((json) {
        print('Parsing medical record: $json');
        return MedicalRecord.fromJson(json);
      }).toList();

      print(
        'Parsed medical records: ${medicalRecords.map((mr) => 'ID: ${mr.medicalRecordId}').join(', ')}',
      );
      return medicalRecords;
    } else {
      print(
        'MedicalRecord API Error: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to load medical records: ${response.body}');
    }
  }
}
