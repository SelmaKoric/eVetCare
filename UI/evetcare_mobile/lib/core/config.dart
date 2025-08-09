import 'dart:io';

final baseUrl = Platform.isAndroid
    ? "http://10.0.2.2:5081"
    : "http://localhost:5081";

final loginEndpoint = "$baseUrl/api/Auth/login";
final patientsEndpoint = "$baseUrl/Pets";
final userInfoEndpoint = "$baseUrl/User";
final genderEndpoint = "$baseUrl/Gender";
final speciesEndpoint = "$baseUrl/Species";
