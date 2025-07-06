class Appointment {
  final String date;
  final String time;
  final String serviceNames;
  final String? status;
  final int appointmentId;

  Appointment({
    required this.date,
    required this.time,
    required this.serviceNames,
    this.status,
    required this.appointmentId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final services = json['serviceNames'];
    String names = "";

    if (services is List) {
      names = services
          .map((s) => s['name'])
          .whereType<String>()
          .join(', ');
    }

    return Appointment(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      serviceNames: names,
      status: json['status'] as String?,
      appointmentId: json['appointmentId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'serviceNames': serviceNames,
      'status': status,
      'appointmentId': appointmentId,
    };
  }
}