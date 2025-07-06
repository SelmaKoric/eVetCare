import 'dart:convert';
import 'package:evetcare_admin/core/auth_utils.dart';
import 'package:evetcare_admin/core/config.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:http/http.dart' as http;

class MedicalRecordProvider {
  Future<List<MedicalRecord>> getMedicalRecordsByPetId(int petId) async {
    final uri = Uri.parse('$baseUrl/MedicalRecord?PetId=$petId&IncludeDiagnoses=true');
    final response = await http.get(uri, headers: createHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> result = data['result'];
      return result.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medical history');
    }
  }
}
