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
    print('=== ADD PET METHOD CALLED ===');
    print('Has image file: ${imageFile != null}');
    print('Pet name: ${pet.name}');
    print('Pet owner ID: ${pet.ownerId}');
    print('============================');

    if (imageFile != null) {
      print('Using _addPetWithImage method');
      return await _addPetWithImage(pet, imageFile);
    } else {
      print('No image file, trying multipart first');
      try {
        return await _addPetWithoutImage(pet);
      } catch (e) {
        print('Multipart failed, trying JSON: $e');
        return await _addPetJson(pet);
      }
    }
  }

  static Future<bool> _addPetWithImage(Pet pet, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(patientsEndpoint),
      );

      if (Authorization.token != null) {
        request.headers["Authorization"] = "Bearer ${Authorization.token}";
      }

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

  static Future<bool> _addPetWithoutImage(Pet pet) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(patientsEndpoint),
      );

      if (Authorization.token != null) {
        request.headers["Authorization"] = "Bearer ${Authorization.token}";
      }

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

      request.fields['photo'] = '';

      request.fields['OwnerId'] = pet.ownerId.toString();
      request.fields['Name'] = pet.name;
      request.fields['SpeciesId'] = pet.speciesId.toString();
      request.fields['Breed'] = pet.breed;
      request.fields['GenderId'] = pet.genderId.toString();
      request.fields['Age'] = pet.age.toString();
      request.fields['Weight'] = pet.weight.toString();
      request.fields['Photo'] = '';

      print('=== ADD PET WITHOUT IMAGE REQUEST DEBUG ===');
      print('URL: $patientsEndpoint');
      print('Method: POST');
      print('Content-Type: multipart/form-data (auto-generated)');
      print(
        'Authorization: Bearer ${Authorization.token != null ? "TOKEN_PRESENT" : "NO_TOKEN"}',
      );
      print('Fields count: ${request.fields.length}');
      print('Files count: ${request.files.length}');
      print('All Fields:');
      request.fields.forEach((key, value) {
        print('  $key: $value');
      });
      print('All Headers:');
      request.headers.forEach((key, value) {
        print('  $key: $value');
      });
      print('============================');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== ADD PET WITHOUT IMAGE RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers:');
      response.headers.forEach((key, value) {
        print('  $key: $value');
      });
      print('Response Body: ${response.body}');
      print('============================');

      ApiLogger.logResponse(
        statusCode: response.statusCode,
        url: patientsEndpoint,
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to add pet without image: ${response.body}");
      }
    } catch (e) {
      print('=== ADD PET WITHOUT IMAGE EXCEPTION ===');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      print('============================');
      throw Exception("Error adding pet without image: $e");
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

    print('=== ADD PET JSON REQUEST DEBUG ===');
    print('URL: $patientsEndpoint');
    print('Method: POST');
    print('Content-Type: application/json');
    print(
      'Authorization: Bearer ${Authorization.token != null ? "TOKEN_PRESENT" : "NO_TOKEN"}',
    );
    print('All Headers:');
    headers.forEach((key, value) {
      print('  $key: $value');
    });
    print('Body: $body');
    print('Pet JSON: ${pet.toJson()}');
    print('============================');

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

    print('=== ADD PET JSON RESPONSE DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers:');
    response.headers.forEach((key, value) {
      print('  $key: $value');
    });
    print('Response Body: ${response.body}');
    print('============================');

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

  static Future<bool> updatePet(int petId, Pet pet, {File? imageFile}) async {
    print('=== UPDATE PET METHOD CALLED ===');
    print('Pet ID: $petId');
    print('Has image file: ${imageFile != null}');
    print('Pet name: ${pet.name}');
    print('============================');

    if (imageFile != null) {
      print('Using _updatePetWithImage method');
      return await _updatePetWithImage(petId, pet, imageFile);
    } else {
      print('No image file, using multipart form data for update');
      return await _updatePetWithoutImage(petId, pet);
    }
  }

  static Future<bool> _updatePetWithoutImage(int petId, Pet pet) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$patientsEndpoint/$petId'),
      );

      if (Authorization.token != null) {
        request.headers["Authorization"] = "Bearer ${Authorization.token}";
      }

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

      request.fields['photo'] = '';

      request.fields['OwnerId'] = pet.ownerId.toString();
      request.fields['Name'] = pet.name;
      request.fields['SpeciesId'] = pet.speciesId.toString();
      request.fields['Breed'] = pet.breed;
      request.fields['GenderId'] = pet.genderId.toString();
      request.fields['Age'] = pet.age.toString();
      request.fields['Weight'] = pet.weight.toString();
      request.fields['Photo'] = '';

      print('=== UPDATE PET WITHOUT IMAGE REQUEST DEBUG ===');
      print('URL: $patientsEndpoint/$petId');
      print('Method: PUT');
      print('Content-Type: multipart/form-data (auto-generated)');
      print(
        'Authorization: Bearer ${Authorization.token != null ? "TOKEN_PRESENT" : "NO_TOKEN"}',
      );
      print('Fields count: ${request.fields.length}');
      print('Files count: ${request.files.length}');
      print('All Fields:');
      request.fields.forEach((key, value) {
        print('  $key: $value');
      });
      print('All Headers:');
      request.headers.forEach((key, value) {
        print('  $key: $value');
      });
      print('============================');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== UPDATE PET WITHOUT IMAGE RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers:');
      response.headers.forEach((key, value) {
        print('  $key: $value');
      });
      print('Response Body: ${response.body}');
      print('============================');

      ApiLogger.logResponse(
        statusCode: response.statusCode,
        url: '$patientsEndpoint/$petId',
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to update pet without image: ${response.body}");
      }
    } catch (e) {
      print('=== UPDATE PET WITHOUT IMAGE EXCEPTION ===');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      print('============================');
      throw Exception("Error updating pet without image: $e");
    }
  }

  static Future<bool> _updatePetWithImage(
    int petId,
    Pet pet,
    File imageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$patientsEndpoint/$petId'),
      );

      if (Authorization.token != null) {
        request.headers["Authorization"] = "Bearer ${Authorization.token}";
      }

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

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'photo',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      print('=== UPDATE PET WITH IMAGE REQUEST DEBUG ===');
      print('URL: $patientsEndpoint/$petId');
      print('Headers: ${request.headers}');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length}');
      print('============================');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      ApiLogger.logResponse(
        statusCode: response.statusCode,
        url: '$patientsEndpoint/$petId',
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to update pet with image: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating pet with image: $e");
    }
  }

  static Future<bool> _updatePetJson(int petId, Pet pet) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (Authorization.token != null) {
      headers["Authorization"] = "Bearer ${Authorization.token}";
    }

    final body = jsonEncode(pet.toJson());

    print('=== UPDATE PET JSON REQUEST DEBUG ===');
    print('URL: $patientsEndpoint/$petId');
    print('Method: PUT');
    print('Content-Type: application/json');
    print(
      'Authorization: Bearer ${Authorization.token != null ? "TOKEN_PRESENT" : "NO_TOKEN"}',
    );
    print('All Headers:');
    headers.forEach((key, value) {
      print('  $key: $value');
    });
    print('Body: $body');
    print('Pet JSON: ${pet.toJson()}');
    print('============================');

    ApiLogger.logRequest(
      method: 'PUT',
      url: '$patientsEndpoint/$petId',
      headers: headers,
      body: body,
    );

    final response = await http.put(
      Uri.parse('$patientsEndpoint/$petId'),
      headers: headers,
      body: body,
    );

    print('=== UPDATE PET JSON RESPONSE DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers:');
    response.headers.forEach((key, value) {
      print('  $key: $value');
    });
    print('Response Body: ${response.body}');
    print('============================');

    ApiLogger.logResponse(
      statusCode: response.statusCode,
      url: '$patientsEndpoint/$petId',
      body: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed to update pet: ${response.body}");
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
