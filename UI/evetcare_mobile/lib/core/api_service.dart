import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import '../models/user.dart';
import '../models/gender.dart';
import '../models/species.dart';
import '../models/pet.dart';
import '../utils/authorization.dart';
import 'config.dart';
import '../utils/logging.dart';

class ApiService {
  static Future<LoginResponse?> login(String email, String password) async {
    ApiLogger.logRequest(
      method: 'POST',
      url: loginEndpoint,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": email, "password": password}),
    );
    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": email, "password": password}),
    );
    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: loginEndpoint,
      body: response.body,
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  static Future<User?> getUserInfo(int userId, String token) async {
    final url = '$userInfoEndpoint/$userId';

    ApiLogger.logRequest(
      method: 'GET',
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: url,
      body: response.body,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to get user info: ${response.body}");
    }
  }

  static Future<List<Gender>> getGenders() async {
    final headers = _getAuthHeaders();

    ApiLogger.logRequest(method: 'GET', url: genderEndpoint, headers: headers);

    final response = await http.get(
      Uri.parse(genderEndpoint),
      headers: headers,
    );

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: genderEndpoint,
      body: response.body,
    );

    if (response.statusCode == 200) {
      final genderResponse = GenderResponse.fromJson(jsonDecode(response.body));
      return genderResponse.result;
    } else {
      throw Exception("Failed to get genders: ${response.body}");
    }
  }

  static Future<List<Species>> getSpecies() async {
    final headers = _getAuthHeaders();

    ApiLogger.logRequest(method: 'GET', url: speciesEndpoint, headers: headers);

    final response = await http.get(
      Uri.parse(speciesEndpoint),
      headers: headers,
    );

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: speciesEndpoint,
      body: response.body,
    );

    if (response.statusCode == 200) {
      final speciesResponse = SpeciesResponse.fromJson(
        jsonDecode(response.body),
      );
      return speciesResponse.result;
    } else {
      throw Exception("Failed to get species: ${response.body}");
    }
  }

  static Future<bool> addPet(Pet pet, {File? imageFile}) async {
    if (imageFile != null) {
      // Use multipart form data for file upload
      return await _addPetWithImage(pet, imageFile);
    } else {
      // Use JSON for data without image
      return await _addPetJson(pet);
    }
  }

  static Future<bool> _addPetWithImage(Pet pet, File imageFile) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(patientsEndpoint),
      );

      // Add authorization header
      if (Authorization.token != null) {
        request.headers["Authorization"] = "Bearer ${Authorization.token}";
      }

      // Add text fields
      request.fields['ownerId'] = pet.ownerId.toString();
      request.fields['ownerFirstName'] = pet.ownerFirstName;
      request.fields['ownerLastName'] = pet.ownerLastName;
      request.fields['ownerEmail'] = pet.ownerEmail;
      request.fields['ownerPhoneNumber'] = pet.ownerPhoneNumber;
      request.fields['name'] = pet.name;
      request.fields['speciesId'] = pet.speciesId.toString();
      request.fields['breed'] = pet.breed;
      request.fields['genderId'] = pet.genderId.toString();
      request.fields['age'] = pet.age.toString();
      request.fields['weight'] = pet.weight.toString();

      // Add image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'photo',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Debug logging
      print('=== ADD PET WITH IMAGE REQUEST DEBUG ===');
      print('URL: $patientsEndpoint');
      print('Headers: ${request.headers}');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length}');
      print('============================');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      ApiLogger.logResponse(
        statusCode: response.statusCode,
        url: patientsEndpoint,
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to add pet with image: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error uploading pet with image: $e");
    }
  }

  static Future<bool> _addPetJson(Pet pet) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (Authorization.token != null) {
      headers["Authorization"] = "Bearer ${Authorization.token}";
    }

    final body = jsonEncode(pet.toJson());

    ApiLogger.logRequest(
      method: 'POST',
      url: patientsEndpoint,
      headers: headers,
      body: body,
    );

    final response = await http.post(
      Uri.parse(patientsEndpoint),
      headers: headers,
      body: body,
    );

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: patientsEndpoint,
      body: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed to add pet: ${response.body}");
    }
  }

  // Helper method to get authenticated headers
  static Map<String, String> _getAuthHeaders() {
    final headers = <String, String>{
      "Content-Type": "application/json; charset=utf-8",
    };

    // Add authorization token if available
    if (Authorization.token != null) {
      headers["Authorization"] = "Bearer ${Authorization.token}";
    }

    return headers;
  }
}
