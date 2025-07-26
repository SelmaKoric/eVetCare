import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/authorization.dart';

class Appointment {
  final int appointmentId;
  final int petId;
  final String petName;
  final String ownerName;
  final String date;
  final String time;
  final List<ServiceName> serviceNames;
  final String status;
  final bool isActive;
  final String? duration; // Add duration field

  Appointment({
    required this.appointmentId,
    required this.petId,
    required this.petName,
    required this.ownerName,
    required this.date,
    required this.time,
    required this.serviceNames,
    required this.status,
    required this.isActive,
    this.duration,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      petId: json['petId'],
      petName: json['petName'],
      ownerName: json['ownerName'],
      date: json['date'],
      time: json['time'],
      serviceNames:
          (json['serviceNames'] as List?)
              ?.map((e) => ServiceName.fromJson(e))
              .toList() ??
          [],
      status: json['status'],
      isActive: json['isActive'] ?? true,
      duration: json['duration'], // Parse duration
    );
  }
}

class ServiceName {
  final String name;
  final String description;
  final bool? isDeleted;

  ServiceName({required this.name, required this.description, this.isDeleted});

  factory ServiceName.fromJson(Map<String, dynamic> json) {
    return ServiceName(
      name: json['name'],
      description: json['description'],
      isDeleted: json['isDeleted'],
    );
  }
}

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;
  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchAppointmentsForDate(DateTime date) async {
    _loading = true;
    notifyListeners();
    final dateStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('http://localhost:5081/Appointments?Date=$dateStr');
    print('[AppointmentProvider] Fetching: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Authorization.token}',
        'Content-Type': 'application/json',
        'accept': 'text/plain',
      },
    );
    print('[AppointmentProvider] Status: ${response.statusCode}');
    print('[AppointmentProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('[AppointmentProvider] Decoded data: $data');
      final List<dynamic> result = data['result'] ?? [];
      print('[AppointmentProvider] result: $result');
      _appointments = result.map((e) => Appointment.fromJson(e)).toList();
      print(
        '[AppointmentProvider] Parsed appointments: ${_appointments.length}',
      );
    } else {
      print('[AppointmentProvider] Error: No appointments loaded');
      _appointments = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchAllAppointments() async {
    _loading = true;
    notifyListeners();
    final url = Uri.parse('http://localhost:5081/Appointments');
    print('[AppointmentProvider] Fetching all appointments: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Authorization.token}',
        'Content-Type': 'application/json',
        'accept': 'text/plain',
      },
    );
    print('[AppointmentProvider] Status: ${response.statusCode}');
    print('[AppointmentProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('[AppointmentProvider] Decoded data: $data');
      final List<dynamic> result = data['result'] ?? [];
      print('[AppointmentProvider] result: $result');
      _appointments = result.map((e) => Appointment.fromJson(e)).toList();
      print(
        '[AppointmentProvider] Parsed appointments: ${_appointments.length}',
      );
    } else {
      print('[AppointmentProvider] Error: No appointments loaded');
      _appointments = [];
    }
    _loading = false;
    notifyListeners();
  }
}
