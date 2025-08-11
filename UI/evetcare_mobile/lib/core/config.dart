import 'dart:io';

// ===== SERVER CONFIGURATION =====
// API Server - Keep 10.0.2.2 for Android emulator
final String apiServerAddress = Platform.isAndroid
    ? "http://10.0.2.2:5081"
    : "http://localhost:5081";

// Image Server - Use localhost for web/iOS, but computer's IP for Android emulator
final String computerIP = "192.168.200.59"; // Your computer's IP address

final String imageServerAddress = Platform.isAndroid
    ? "http://$computerIP:5081" // Android emulator needs your computer's IP
    : "http://localhost:5081"; // Web and iOS can use localhost

final baseUrl = apiServerAddress;

final loginEndpoint = "$baseUrl/api/Auth/login";
final patientsEndpoint = "$baseUrl/Pets";
final userInfoEndpoint = "$baseUrl/User";
final genderEndpoint = "$baseUrl/Gender";
final speciesEndpoint = "$baseUrl/Species";

// Utility function to build complete image URLs
String buildImageUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) {
    return '';
  }

  // If it's already a full URL, return as is
  if (relativePath.startsWith('http://') ||
      relativePath.startsWith('https://')) {
    return relativePath;
  }

  // If it starts with a slash, combine with image server URL
  if (relativePath.startsWith('/')) {
    return '$imageServerAddress$relativePath';
  }

  // Otherwise, assume it's relative to image server URL
  return '$imageServerAddress/$relativePath';
}
