import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../providers/api_provider.dart';
import '../utils/authorization.dart';

class AppointmentService {
  static Future<List<Appointment>> getAppointments() async {
    final response = await ApiProvider.get(
      '/Appointments?OwnerId=${Authorization.userId}',
    );

    List<dynamic> appointmentsData;
    if (response is Map && response.containsKey('result')) {
      appointmentsData = response['result'] ?? [];
    } else if (response is List) {
      appointmentsData = response;
    } else {
      appointmentsData = [];
    }

    return appointmentsData.map((appointment) {
      return Appointment.fromJson(appointment);
    }).toList();
  }

  static Future<Map<String, dynamic>> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    return await ApiProvider.createAppointment(appointmentData);
  }

  static Future<Map<String, dynamic>> updateAppointment(
    int appointmentId,
    Map<String, dynamic> appointmentData,
  ) async {
    return await ApiProvider.put(
      '/Appointments/$appointmentId',
      appointmentData,
    );
  }

  // Cancel an appointment
  static Future<void> cancelAppointment(int appointmentId) async {
    await ApiProvider.cancelAppointment(appointmentId);
  }

  // Create an invoice
  static Future<Map<String, dynamic>> createInvoice(
    Map<String, dynamic> invoiceData,
  ) async {
    return await ApiProvider.createInvoice(invoiceData);
  }

  // Get pets for the current user
  static Future<List<Map<String, dynamic>>> getPets() async {
    final response = await ApiProvider.get(
      '/Pets?OwnerId=${Authorization.userId}',
    );

    List<dynamic> petsData;
    if (response is List) {
      petsData = response;
    } else if (response is Map && response.containsKey('result')) {
      petsData = response['result'] ?? [];
    } else if (response is Map && response.containsKey('resultList')) {
      petsData = response['resultList'] ?? [];
    } else {
      petsData = [];
    }

    return petsData.cast<Map<String, dynamic>>();
  }

  // Get all services
  static Future<List<Map<String, dynamic>>> getServices() async {
    final response = await ApiProvider.get('/Services');

    List<dynamic> servicesData;
    if (response is List) {
      servicesData = response;
    } else if (response is Map && response.containsKey('result')) {
      servicesData = response['result'] ?? [];
    } else if (response is Map && response.containsKey('resultList')) {
      servicesData = response['resultList'] ?? [];
    } else {
      servicesData = [];
    }

    return servicesData.cast<Map<String, dynamic>>();
  }

  // Filter appointments by status
  static List<Appointment> filterByStatus(
    List<Appointment> appointments,
    String status,
  ) {
    if (status == 'All') return appointments;

    return appointments.where((appointment) {
      final appointmentStatus = appointment.status.trim().toLowerCase();
      final filterStatus = status.trim().toLowerCase();
      return appointmentStatus == filterStatus;
    }).toList();
  }

  // Sort appointments by date (newest first)
  static List<Appointment> sortByDate(List<Appointment> appointments) {
    final sortedAppointments = List<Appointment>.from(appointments);
    sortedAppointments.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA); // Newest first
      } catch (e) {
        return 0;
      }
    });
    return sortedAppointments;
  }

  // Get appointments by date range
  static List<Appointment> filterByDateRange(
    List<Appointment> appointments,
    DateTime startDate,
    DateTime endDate,
  ) {
    return appointments.where((appointment) {
      try {
        final appointmentDate = DateTime.parse(appointment.date);
        return appointmentDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get appointments by pet
  static List<Appointment> filterByPet(
    List<Appointment> appointments,
    int petId,
  ) {
    return appointments
        .where((appointment) => appointment.petId == petId)
        .toList();
  }

  // Get appointments by service
  static List<Appointment> filterByService(
    List<Appointment> appointments,
    String serviceName,
  ) {
    return appointments.where((appointment) {
      return appointment.serviceNames.any(
        (service) =>
            service.name.toLowerCase().contains(serviceName.toLowerCase()),
      );
    }).toList();
  }

  // Search appointments by text
  static List<Appointment> searchAppointments(
    List<Appointment> appointments,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return appointments;

    final lowerSearchTerm = searchTerm.toLowerCase();

    return appointments.where((appointment) {
      return appointment.petName.toLowerCase().contains(lowerSearchTerm) ||
          appointment.ownerName.toLowerCase().contains(lowerSearchTerm) ||
          appointment.serviceNames.any(
            (service) => service.name.toLowerCase().contains(lowerSearchTerm),
          ) ||
          appointment.status.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  // Format date for display
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference == -1) {
        return 'Yesterday';
      } else if (difference > 0) {
        return 'In $difference days';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Format duration for display
  static String formatDuration(String duration) {
    final parts = duration.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    if (hours == 0) {
      return '${minutes} minutes';
    } else if (minutes == 0) {
      return '${hours} hour${hours > 1 ? 's' : ''}';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color.fromARGB(255, 90, 183, 226);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Get status text color
  static Color getStatusTextColor(String status) {
    return Colors.white; // All status chips use white text
  }

  // Validate appointment data
  static String? validateAppointmentData({
    int? petId,
    List<int>? serviceIds,
    DateTime? date,
    TimeOfDay? time,
  }) {
    if (petId == null) {
      return 'Please select a pet';
    }
    if (serviceIds == null || serviceIds.isEmpty) {
      return 'Please select at least one service';
    }
    if (date == null) {
      return 'Please select a date';
    }
    if (time == null) {
      return 'Please select a time';
    }
    return null;
  }

  // Prepare appointment data for API
  static Map<String, dynamic> prepareAppointmentData({
    required int petId,
    required DateTime date,
    required TimeOfDay time,
    required String duration,
    required List<int> serviceIds,
    int appointmentStatus = 1,
    bool createdByAdmin = false,
  }) {
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return {
      "petId": petId,
      "date": dateTime.toIso8601String(),
      "time":
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
      "duration": duration,
      "serviceIds": serviceIds,
      "appointmentStatus": appointmentStatus,
      "createdByAdmin": createdByAdmin,
    };
  }

  // Parse time string to TimeOfDay
  static TimeOfDay? parseTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  // Get appointment statistics
  static Map<String, int> getStatistics(List<Appointment> appointments) {
    int total = appointments.length;
    int approved = appointments
        .where((a) => a.status.toLowerCase() == 'approved')
        .length;
    int completed = appointments
        .where((a) => a.status.toLowerCase() == 'completed')
        .length;
    int cancelled = appointments
        .where((a) => a.status.toLowerCase() == 'cancelled')
        .length;
    int pending = appointments
        .where((a) => a.status.toLowerCase() == 'pending')
        .length;

    return {
      'total': total,
      'approved': approved,
      'completed': completed,
      'cancelled': cancelled,
      'pending': pending,
    };
  }

  // Handle appointment error messages
  static Map<String, dynamic> handleAppointmentError(dynamic error) {
    String errorMessage = 'An error occurred';
    bool isOverlapError = false;

    if (error.toString().contains('overlaps with the requested time')) {
      errorMessage =
          'Time slot unavailable. There is already an appointment scheduled that overlaps with the requested time. Please select a different date or time.';
      isOverlapError = true;
    } else if (error.toString().contains('overlap')) {
      errorMessage =
          'This time slot conflicts with an existing appointment. Please choose a different time.';
      isOverlapError = true;
    } else {
      errorMessage = error.toString();
    }

    return {'message': errorMessage, 'isOverlapError': isOverlapError};
  }
}
