import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/service_provider.dart';
import '../models/patient.dart';
import '../models/service.dart';
import 'dart:convert'; // Added for jsonEncode
import 'package:http/http.dart' as http; // Added for http
import '../core/auth_utils.dart'; // For createHeaders

class AppointmentsCalendarPage extends StatefulWidget {
  const AppointmentsCalendarPage({super.key});

  @override
  State<AppointmentsCalendarPage> createState() =>
      _AppointmentsCalendarPageState();
}

class _AppointmentsCalendarPageState extends State<AppointmentsCalendarPage> {
  EventController? _controller;
  DateTime _selectedDate = DateTime.now();
  bool _eventsAddedForDate = false;
  List<Appointment> _lastMappedAppointments = [];
  bool _didInitialFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = CalendarControllerProvider.of(context).controller;
    }
  }

  @override
  void didUpdateWidget(covariant AppointmentsCalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _didInitialFetch = false;
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eventsAddedForDate = false;
        _didInitialFetch = false;
      });
    }
  }

  void _mapAppointmentsToEvents(List<Appointment> appointments) {
    print(
      'Mapping appointments for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}:',
    );
    print(
      appointments
          .map((a) => 'id:${a.appointmentId} time:${a.time} pet:${a.petName}')
          .toList(),
    );
    _controller?.removeWhere((event) => true); // Clear all events
    for (final appt in appointments) {
      final timeParts = appt.time.split(":");
      final startHour = int.tryParse(timeParts[0]) ?? 0;
      final startMinute = int.tryParse(timeParts[1]) ?? 0;
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        startHour,
        startMinute,
      );
      final end = start.add(const Duration(hours: 1));
      print('Adding event: ${appt.petName} $start - $end');
      _controller?.add(
        CalendarEventData(
          title: appt.petName,
          date: _selectedDate,
          startTime: start,
          endTime: end,
          description: "Owner: ${appt.ownerName}",
          color: _getStatusColor(appt.status),
        ),
      );
    }
    _eventsAddedForDate = true;
    _lastMappedAppointments = appointments;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_didInitialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('Fetching appointments for $_selectedDate');
          Provider.of<AppointmentProvider>(
            context,
            listen: false,
          ).fetchAppointmentsForDate(_selectedDate);
          _didInitialFetch = true;
        }
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Select Date:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddAppointmentDialog(context, _selectedDate),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Appointment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, _) {
                  print(
                    'Provider appointments for $_selectedDate: ${provider.appointments.length}',
                  );
                  if (!_eventsAddedForDate ||
                      provider.appointments != _lastMappedAppointments) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _mapAppointmentsToEvents(provider.appointments);
                      }
                    });
                  }
                  if (provider.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.appointments.isEmpty) {
                    return const Center(
                      child: Text('No appointments for this date.'),
                    );
                  }
                  return DayView(
                    controller: _controller,
                    minDay: _selectedDate,
                    maxDay: _selectedDate,
                    initialDay: _selectedDate,
                    heightPerMinute: 1.0,
                    startHour: 0,
                    endHour: 24,
                    showVerticalLine: true,
                    timeLineWidth: 60,
                    timeLineBuilder: (date) {
                      return Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          DateFormat('HH:mm').format(date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    eventTileBuilder: (date, events, bound, start, end) {
                      final event = events.first;
                      return Positioned(
                        top: bound.top,
                        left: bound.left,
                        width: bound.width,
                        height: bound.height,
                        child: Container(
                          decoration: BoxDecoration(
                            color: event.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.title ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              if (event.description != null &&
                                  event.description!.isNotEmpty)
                                Text(
                                  event.description!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 2,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddAppointmentDialog(BuildContext context, DateTime selectedDate) {
  showDialog(
    context: context,
    builder: (context) => _AddAppointmentDialog(selectedDate: selectedDate),
  );
}

class _AddAppointmentDialog extends StatefulWidget {
  final DateTime selectedDate;
  const _AddAppointmentDialog({Key? key, required this.selectedDate})
    : super(key: key);
  @override
  State<_AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<_AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _petId;
  DateTime? _date;
  TimeOfDay? _time;
  String? _duration;
  List<int> _serviceIds = [];

  List<Patient> _pets = [];
  List<Service> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLookups();
  }

  Future<void> _fetchLookups() async {
    setState(() {
      _loading = true;
    });
    try {
      final patientProvider = PatientProvider();
      final serviceProvider = ServiceProvider();
      final pets = await patientProvider.get();
      final services = await serviceProvider.get();
      setState(() {
        _pets = pets.result;
        _services = services.result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load options: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  List<String> get _durationOptions {
    List<String> options = [];
    for (int min = 30; min <= 240; min += 30) {
      options.add(min.toString()); // Store minutes as string
    }
    return options;
  }

  String _durationLabel(String minutesStr) {
    final min = int.tryParse(minutesStr) ?? 0;
    if (min == 30) return '30 min';
    final h = min ~/ 60;
    final m = min % 60;
    if (m == 0) {
      return ' $h hour${h > 1 ? 's' : ''}';
    } else {
      return ' $h hour${h > 1 ? 's' : ''} $m min';
    }
  }

  String _durationToBackend(String minutesStr) {
    final min = int.tryParse(minutesStr) ?? 0;
    final h = (min ~/ 60).toString().padLeft(2, '0');
    final m = (min % 60).toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Appointment'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
            ? SizedBox(height: 120, child: Center(child: Text(_error!)))
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pet Dropdown
                      DropdownButtonFormField<int>(
                        value: _petId,
                        decoration: const InputDecoration(labelText: 'Pet'),
                        items: _pets.where((pet) => pet.petId != null).map((
                          pet,
                        ) {
                          return DropdownMenuItem<int>(
                            value: pet.petId!,
                            child: Text(
                              '${pet.name ?? ''} (${pet.ownerName ?? ''})',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _petId = val),
                        validator: (val) =>
                            val == null ? 'Pet is required' : null,
                      ),
                      // Date
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Date'),
                        controller: TextEditingController(
                          text: _date == null
                              ? ''
                              : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}',
                        ),
                        onTap: _pickDate,
                        validator: (value) =>
                            _date == null ? 'Date is required' : null,
                      ),
                      // Time
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Time'),
                        controller: TextEditingController(
                          text: _time == null ? '' : _time!.format(context),
                        ),
                        onTap: _pickTime,
                        validator: (value) =>
                            _time == null ? 'Time is required' : null,
                      ),
                      // Duration Dropdown
                      DropdownButtonFormField<String>(
                        value: _duration,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                        ),
                        items: _durationOptions
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(_durationLabel(d)),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _duration = val),
                        validator: (val) =>
                            val == null ? 'Duration is required' : null,
                      ),
                      // Services Multi-select
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 4.0,
                          ),
                          child: Text(
                            'Services',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: _services
                            .where((service) => service.serviceId != null)
                            .map((service) {
                              final selected = _serviceIds.contains(
                                service.serviceId,
                              );
                              return FilterChip(
                                label: Text(service.name),
                                selected: selected,
                                onSelected: (isSelected) {
                                  setState(() {
                                    if (isSelected) {
                                      _serviceIds.add(service.serviceId!);
                                    } else {
                                      _serviceIds.remove(service.serviceId!);
                                    }
                                  });
                                },
                              );
                            })
                            .toList(),
                      ),
                      if (_serviceIds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Select at least one service',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_formKey.currentState!.validate() &&
                      _serviceIds.isNotEmpty) {
                    setState(() {
                      _loading = true;
                    });
                    final appointmentData = {
                      'petId': _petId,
                      'date': _date != null ? _date!.toIso8601String() : null,
                      'time': _time != null ? _time!.format(context) : null,
                      'duration': _duration != null
                          ? _durationToBackend(_duration!)
                          : null,
                      'serviceIds': _serviceIds,
                      'appointmentStatus': 2,
                    };
                    try {
                      final response = await http.post(
                        Uri.parse('http://localhost:5081/Appointments'),
                        headers: createHeaders(),
                        body: jsonEncode(appointmentData),
                      );
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        Navigator.of(context).pop();
                        // Refresh calendar for the selected date
                        final appointmentProvider =
                            Provider.of<AppointmentProvider>(
                              context,
                              listen: false,
                            );
                        appointmentProvider.fetchAppointmentsForDate(
                          widget.selectedDate,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to add appointment: ${response.body}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    } finally {
                      if (mounted)
                        setState(() {
                          _loading = false;
                        });
                    }
                  }
                },
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
