import 'package:flutter/material.dart';
import 'book_appointment_page.dart';
import 'edit_appointment_page.dart';
import '../utils/authorization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  List<Appointment> _appointments = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (Authorization.userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5081/Appointments?OwnerId=${Authorization.userId}',
        ),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
      );

      print(
        'Appointments API Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<dynamic> appointmentsData;
        if (responseData is Map && responseData.containsKey('result')) {
          appointmentsData = responseData['result'] ?? [];
        } else if (responseData is List) {
          appointmentsData = responseData;
        } else {
          appointmentsData = [];
        }

        setState(() {
          _appointments = appointmentsData.map((appointment) {
            return Appointment.fromJson(appointment);
          }).toList();
        });

        print('Loaded ${_appointments.length} appointments');
      } else {
        throw Exception(
          'Failed to load appointments: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load appointments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text(
          "Appointment History",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
            onPressed: _loadAppointments,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'All', child: Text('All')),
              const PopupMenuItem<String>(
                value: 'Approved',
                child: Text('Approved'),
              ),
              const PopupMenuItem<String>(
                value: 'Completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem<String>(
                value: 'Cancelled',
                child: Text('Cancelled'),
              ),
              const PopupMenuItem<String>(
                value: 'Pending',
                child: Text('Pending'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.filter_list, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 90, 183, 226),
                ),
              ),
            )
          : Column(
              children: [
                // Filter indicator
                if (_selectedFilter != 'All')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Showing: $_selectedFilter',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All';
                            });
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 90, 183, 226),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Appointments list
                Expanded(
                  child: filteredAppointments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return _buildAppointmentCard(appointment);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    if (_selectedFilter == 'All') {
      return _appointments;
    }
    return _appointments
        .where((a) => a.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter or book a new appointment',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isApproved = appointment.status.toLowerCase() == 'approved';
    final isCompleted = appointment.status.toLowerCase() == 'completed';
    final isCancelled = appointment.status.toLowerCase() == 'cancelled';
    final isPending = appointment.status.toLowerCase() == 'pending';

    return GestureDetector(
      onTap: isPending ? () => _editPendingAppointment(appointment) : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceNames.isNotEmpty
                              ? appointment.serviceNames.first.name
                              : 'No Service',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (appointment.serviceNames.length > 1)
                          Text(
                            '+${appointment.serviceNames.length - 1} more services',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
              const SizedBox(height: 12),

              // Pet name
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    appointment.petName,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date and time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(appointment.date),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    appointment.time,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    appointment.duration,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Action buttons for approved appointments
              if (isApproved) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _editAppointment(appointment),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            90,
                            183,
                            226,
                          ),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 90, 183, 226),
                          ),
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rescheduleAppointment(appointment),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _cancelAppointment(appointment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String text = status;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = const Color.fromARGB(255, 90, 183, 226);
        textColor = Colors.white;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
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
        return '${date.month}/${date.day}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _rescheduleAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reschedule Appointment'),
          content: const Text('Would you like to reschedule this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRescheduleDialog(appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reschedule'),
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(Appointment appointment) {
    DateTime? newDate = DateTime.tryParse(appointment.date);
    TimeOfDay? newTime = _parseTimeString(appointment.time);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select New Date & Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date picker
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(
                      newDate != null
                          ? "${newDate!.month}/${newDate!.day}/${newDate!.year}"
                          : "Select date",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: newDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          newDate = picked;
                        });
                      }
                    },
                  ),
                  // Time picker
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Time'),
                    subtitle: Text(
                      newTime != null
                          ? newTime!.format(context)
                          : "Select time",
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: newTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          newTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newDate != null && newTime != null) {
                      Navigator.of(context).pop();
                      _updateAppointment(appointment, newDate!, newTime!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select both date and time'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  void _editAppointment(Appointment appointment) {
    // Navigate to book appointment page with pre-filled data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookAppointmentPage(editingAppointment: appointment),
      ),
    ).then((updatedAppointment) {
      if (updatedAppointment != null) {
        setState(() {
          final index = _appointments.indexWhere(
            (a) => a.appointmentId == appointment.appointmentId,
          );
          if (index != -1) {
            _appointments[index] = updatedAppointment;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _editPendingAppointment(Appointment appointment) {
    // Navigate to edit appointment page for pending appointments
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAppointmentPage(appointment: appointment),
      ),
    ).then((success) {
      if (success == true) {
        // Refresh the appointments list
        _loadAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pending appointment updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _updateAppointment(
    Appointment appointment,
    DateTime newDate,
    TimeOfDay newTime,
  ) {
    // TODO: Call API to update appointment
    setState(() {
      final index = _appointments.indexWhere(
        (a) => a.appointmentId == appointment.appointmentId,
      );
      if (index != -1) {
        _appointments[index] = Appointment(
          appointmentId: appointment.appointmentId,
          petId: appointment.petId,
          petName: appointment.petName,
          ownerName: appointment.ownerName,
          date:
              "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}",
          time:
              "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}",
          serviceNames: appointment.serviceNames,
          status: appointment.status,
          duration: appointment.duration,
          isActive: appointment.isActive,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment rescheduled successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Text(
            'Are you sure you want to cancel the appointment for ${appointment.petName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Call API to cancel appointment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}

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
      status: json['status'] ?? '',
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
