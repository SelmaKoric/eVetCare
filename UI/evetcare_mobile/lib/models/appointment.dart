class Appointment {
  final int appointmentId;
  final int petId;
  final String petName;
  final String ownerName;
  final String date;
  final String time;
  final List<ServiceName> serviceNames;
  final String status;
  final String duration;
  final bool isActive;

  Appointment({
    required this.appointmentId,
    required this.petId,
    required this.petName,
    required this.ownerName,
    required this.date,
    required this.time,
    required this.serviceNames,
    required this.status,
    required this.duration,
    required this.isActive,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String normalizeStatus(String status) {
      if (status.isEmpty) return status;
      return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }

    return Appointment(
      appointmentId: json['appointmentId'] ?? 0,
      petId: json['petId'] ?? 0,
      petName: json['petName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      serviceNames:
          (json['serviceNames'] as List<dynamic>?)
              ?.map((service) => ServiceName.fromJson(service))
              .toList() ??
          [],
      status: normalizeStatus(json['status'] ?? ''),
      duration: json['duration'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}

class ServiceName {
  final int id;
  final String name;
  final String description;

  ServiceName({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ServiceName.fromJson(Map<String, dynamic> json) {
    return ServiceName(
      id: json['id'] ?? json['serviceId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
