import 'dart:io';

final baseUrl = Platform.isAndroid
    ? "http://10.0.2.2:5000"
    : "http://localhost:5000";


final loginEndpoint = "$baseUrl/api/Auth/login";
final patientsEndpoint = "$baseUrl/Pets";