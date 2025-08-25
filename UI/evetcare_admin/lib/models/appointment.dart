class Appointment {
  final String date;
  final String time;
  final List<ServiceName> serviceNames;
  final String? status;
  final int appointmentId;
  final int petId;
  final int? medicalRecordId;
  final String petName;
  final String ownerName;
  final String duration;

  Appointment({
    required this.date,
    required this.time,
    required this.serviceNames,
    this.status,
    required this.appointmentId,
    required this.petId,
    this.medicalRecordId,
    required this.petName,
    required this.ownerName,
    required this.duration,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final services = json['serviceNames'];
    List<ServiceName> serviceNamesList = [];

    if (services is List) {
      serviceNamesList = services
          .map((s) => ServiceName.fromJson(s))
          .whereType<ServiceName>()
          .toList();
    } else if (services is String && services.isNotEmpty) {
      serviceNamesList = [ServiceName(name: services, description: '')];
    }

    return Appointment(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      serviceNames: serviceNamesList,
      status: json['status'] as String?,
      appointmentId: json['appointmentId'] ?? 0,
      petId: json['petId'] ?? 0,
      medicalRecordId: json['medicalRecordId'] as int?,
      petName: json['petName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'serviceNames': serviceNames.map((s) => s.toJson()).toList(),
      'status': status,
      'appointmentId': appointmentId,
      'petId': petId,
      'medicalRecordId': medicalRecordId,
      'petName': petName,
      'ownerName': ownerName,
      'duration': duration,
    };
  }

  String get serviceNamesString {
    return serviceNames.map((s) => s.name).join(', ');
  }
}

class ServiceName {
  final String name;
  final String description;

  ServiceName({required this.name, required this.description});

  factory ServiceName.fromJson(Map<String, dynamic> json) {
    return ServiceName(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
