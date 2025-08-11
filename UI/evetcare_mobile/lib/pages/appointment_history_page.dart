import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'edit_appointment_page.dart';

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
      final appointments = await AppointmentService.getAppointments();

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });

      print('Loaded ${_appointments.length} appointments');

      // Debug: Print all status values from loaded appointments
      final statuses = _appointments.map((a) => a.status).toSet();
      print('Status values from API: $statuses');

      // Debug: Print first few appointments with their status
      for (int i = 0; i < _appointments.length && i < 3; i++) {
        print(
          'Appointment ${i + 1}: ID=${_appointments[i].appointmentId}, Status="${_appointments[i].status}"',
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = AppointmentService.filterByStatus(
      _appointments,
      _selectedFilter,
    );

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
                    AppointmentService.formatDate(appointment.date),
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
                    AppointmentService.formatDuration(appointment.duration),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Action buttons for approved and pending appointments
              if (isApproved || isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (isApproved) ...[
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
                    ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppointmentService.getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppointmentService.getStatusTextColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
    TimeOfDay? newTime = AppointmentService.parseTimeString(appointment.time);

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
                          ? "${newDate!.day.toString().padLeft(2, '0')}/${newDate!.month.toString().padLeft(2, '0')}/${newDate!.year}"
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

  void _editAppointment(Appointment appointment) {
    // This would navigate to a book appointment page with editing mode
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality will be implemented soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _editPendingAppointment(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAppointmentPage(appointment: appointment),
      ),
    ).then((success) {
      if (success == true) {
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

  Future<void> _cancelAppointment(Appointment appointment) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Text(
            'Are you sure you want to cancel the appointment for ${appointment.petName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
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

    if (shouldCancel != true) {
      return;
    }

    try {
      print('Cancelling appointment ID: ${appointment.appointmentId}');
      print('Appointment status: ${appointment.status}');

      await AppointmentService.cancelAppointment(appointment.appointmentId);

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
            date: appointment.date,
            time: appointment.time,
            serviceNames: appointment.serviceNames,
            status: 'Cancelled',
            duration: appointment.duration,
            isActive: false,
          );

          print(
            'Updated appointment ${appointment.appointmentId} status to: Cancelled',
          );
          print(
            'Current appointments statuses: ${_appointments.map((a) => '${a.appointmentId}:${a.status}').toList()}',
          );
        } else {
          print(
            'Could not find appointment ${appointment.appointmentId} in local list',
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error cancelling appointment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
