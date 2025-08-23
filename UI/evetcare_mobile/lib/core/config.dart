import 'dart:io';

// ===== SERVER CONFIGURATION =====
// API Server - Keep 10.0.2.2 for Android emulator
final String apiServerAddress = Platform.isAndroid
    ? "http://10.0.2.2:5081"
    : "http://localhost:5081";

// Config class for consistent API access
class Config {
  static String get apiUrl => apiServerAddress;
}

final String computerIP = "192.168.200.59";
final String imageServerAddress = Platform.isAndroid
    ? "http://$computerIP:5081"
    : "http://localhost:5081";

final baseUrl = apiServerAddress;

final loginEndpoint = "$baseUrl/api/Auth/login";
final patientsEndpoint = "$baseUrl/Pets";
final userInfoEndpoint = "$baseUrl/User";
final genderEndpoint = "$baseUrl/Gender";
final speciesEndpoint = "$baseUrl/Species";

String buildImageUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) {
    return '';
  }

  if (relativePath.startsWith('http://') ||
      relativePath.startsWith('https://')) {
    return relativePath;
  }

  if (relativePath.startsWith('/')) {
    return '$imageServerAddress$relativePath';
  }

  return '$imageServerAddress/$relativePath';
}
