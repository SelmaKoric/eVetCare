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
import '../utils/authorization.dart'; // For Authorization.token

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
    _controller ??= CalendarControllerProvider.of(context).controller;
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
      // Parse duration (HH:mm:ss)
      Duration duration = const Duration(hours: 1); // default
      if (appt.duration != null) {
        final durParts = appt.duration!.split(":");
        if (durParts.length >= 2) {
          final h = int.tryParse(durParts[0]) ?? 0;
          final m = int.tryParse(durParts[1]) ?? 0;
          final s = durParts.length > 2 ? int.tryParse(durParts[2]) ?? 0 : 0;
          duration = Duration(hours: h, minutes: m, seconds: s);
        }
      }
      final end = start.add(duration);
      print(
        'Adding event: ${appt.petName} $start - $end (duration: $duration)',
      );
      _controller?.add(
        CalendarEventData(
          title: appt.petName,
          date: _selectedDate,
          startTime: start,
          endTime: end,
          description: "Owner: ${appt.ownerName}",
          color: _getStatusColor(appt.status),
          event: appt, // <-- ADD THIS LINE
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
                      // Extract owner name from description ("Owner: ...")
                      String ownerName = '';
                      if (event.description != null &&
                          event.description!.startsWith('Owner: ')) {
                        ownerName = event.description!.substring(7);
                      }
                      // Compose title: PetName (OwnerName)
                      final titleText = ownerName.isNotEmpty
                          ? '${event.title} ($ownerName)'
                          : event.title ?? '';
                      // Extract services from event (if available)
                      String servicesText = '';
                      if (event.event != null && event.event is Appointment) {
                        final appt = event.event as Appointment;
                        final sn = appt.serviceNames;
                        servicesText = sn
                            .map(
                              (s) => s is ServiceName
                                  ? s.name
                                  : (s is String ? s : ''),
                            )
                            .where((s) => s.toString().isNotEmpty)
                            .join(', ');
                      }
                      // Show services if available and not empty
                      final showServices = servicesText.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          color: event.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                titleText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            if (showServices)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  servicesText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    onEventTap: (events, date) {
                      print('onEventTap triggered!'); // Debug print
                      final event = events.first;
                      print('Tapped event: $event'); // Debug print
                      if (event.event is Appointment) {
                        final appt = event.event as Appointment;
                        showDialog(
                          context: context,
                          builder: (context) => _EditAppointmentDialog(
                            appointment: appt,
                            selectedDate: _selectedDate,
                          ),
                        );
                      }
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
  const _AddAppointmentDialog({super.key, required this.selectedDate});
  @override
  State<_AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<_AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _petId;
  DateTime? _date;
  TimeOfDay? _time;
  String? _duration;
  final List<int> _serviceIds = [];

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
                                      _serviceIds.add(service.serviceId);
                                    } else {
                                      _serviceIds.remove(service.serviceId);
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
                    // Format time as HH:mm:ss
                    String? formattedTime;
                    if (_time != null) {
                      final hour = _time!.hour.toString().padLeft(2, '0');
                      final minute = _time!.minute.toString().padLeft(2, '0');
                      formattedTime = '$hour:$minute:00';
                    }
                    // Format duration as HH:mm:ss
                    String? formattedDuration;
                    if (_duration != null) {
                      final min = int.tryParse(_duration!) ?? 0;
                      final h = (min ~/ 60).toString().padLeft(2, '0');
                      final m = (min % 60).toString().padLeft(2, '0');
                      formattedDuration = '$h:$m:00';
                    }
                    final appointmentData = {
                      'petId': _petId,
                      'date': _date?.toIso8601String(),
                      'time': formattedTime,
                      'duration': formattedDuration,
                      'serviceIds': _serviceIds,
                      'appointmentStatus': 2, // Hardcoded
                      'createdByAdmin': true, // Hardcoded
                    };
                    try {
                      final response = await http.post(
                        Uri.parse('http://localhost:5081/Appointments'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer ${Authorization.token}',
                          'accept': 'text/plain',
                        },
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
                              'Failed to add appointment:  {response.body}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error:  {e.toString()}')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _loading = false;
                        });
                      }
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

class _EditAppointmentDialog extends StatefulWidget {
  final Appointment appointment;
  final DateTime selectedDate;
  const _EditAppointmentDialog({
    super.key,
    required this.appointment,
    required this.selectedDate,
  });
  @override
  State<_EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<_EditAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _petId;
  DateTime? _date;
  TimeOfDay? _time;
  String? _duration;
  List<int> _serviceIds = [];
  String? _status;

  List<Patient> _pets = [];
  List<Service> _services = [];
  bool _loading = true;
  String? _error;

  final List<String> _statusOptions = [
    'pending',
    'approved',
    'rejected',
    'completed',
    'canceled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLookups();
    _initFieldsFromAppointment();
  }

  void _initFieldsFromAppointment() {
    final appt = widget.appointment;
    _petId = appt.petId;
    _date = DateTime.tryParse(appt.date);
    final timeParts = appt.time.split(":");
    if (timeParts.length >= 2) {
      _time = TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 0,
        minute: int.tryParse(timeParts[1]) ?? 0,
      );
    }
    if (appt.duration != null) {
      final durParts = appt.duration!.split(":");
      if (durParts.length >= 2) {
        final min =
            (int.tryParse(durParts[0]) ?? 0) * 60 +
            (int.tryParse(durParts[1]) ?? 0);
        _duration = min.toString();
      }
    }
    _serviceIds = appt.serviceNames is List
        ? (appt.serviceNames as List)
              .map((s) {
                if (s is ServiceName) {
                  final match = _services.firstWhere(
                    (srv) => srv.name == s.name,
                    orElse: () => Service(
                      serviceId: -1,
                      name: '',
                      description: '',
                      categoryId: 0,
                      categoryName: '',
                      price: 0.0,
                      durationMinutes: 0,
                    ),
                  );
                  return match.serviceId;
                } else if (s is String) {
                  final match = _services.firstWhere(
                    (srv) => srv.name == s,
                    orElse: () => Service(
                      serviceId: -1,
                      name: '',
                      description: '',
                      categoryId: 0,
                      categoryName: '',
                      price: 0.0,
                      durationMinutes: 0,
                    ),
                  );
                  return match.serviceId;
                }
                return null;
              })
              .whereType<int>()
              .where((id) => id != -1)
              .toList()
        : [];
    _status = appt.status.toLowerCase();
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
        _initFieldsFromAppointment();
        // Ensure _petId is valid
        if (_petId != null && !_pets.any((pet) => pet.petId == _petId)) {
          _petId = null;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load options:  [200~ [0m${e.toString()}';
        _loading = false;
      });
    }
  }

  List<String> get _durationOptions {
    List<String> options = [];
    for (int min = 30; min <= 240; min += 30) {
      options.add(min.toString());
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
    print('=== BUILDING EDIT DIALOG ===');
    print('_status: "$_status"');
    print('widget.appointment.status: "${widget.appointment.status}"');
    final isPending = _status == 'pending';
    final isApproved = _status == 'approved';
    print('isPending: $isPending');
    print('isApproved: $isApproved');
    return AlertDialog(
      title: const Text('Edit Appointment'),
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
                        onTap: () async {
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
                        },
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
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _time ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _time = picked;
                            });
                          }
                        },
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
                                label: Text(
                                  service.name,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.grey[200],
                                onSelected: null, // Make chips read-only
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
        if (isPending) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: _loading
                ? null
                : () async {
                    print('=== REJECT BUTTON PRESSED ===');
                    print(
                      'Appointment ID: ${widget.appointment.appointmentId}',
                    );
                    print('Appointment Status: ${widget.appointment.status}');
                    print(
                      'Is Pending: ${widget.appointment.status.toLowerCase() == 'pending'}',
                    );
                    print(
                      'Token: ${Authorization.token != null ? 'Present' : 'Missing'}',
                    );

                    setState(() {
                      _loading = true;
                    });
                    try {
                      final url =
                          'http://localhost:5081/Appointments/${widget.appointment.appointmentId}/reject';
                      print('Rejecting appointment: $url');
                      print(
                        'Request headers: ${{'Content-Type': 'application/json', 'Authorization': 'Bearer ${Authorization.token}', 'accept': 'text/plain'}}',
                      );

                      final response = await http.put(
                        Uri.parse(url),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer ${Authorization.token}',
                          'accept': 'text/plain',
                        },
                        body: jsonEncode({}),
                      );
                      print('Reject response status: ${response.statusCode}');
                      print('Reject response body: ${response.body}');
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        Navigator.of(context).pop();
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
                              'Failed to reject appointment: \n${response.body}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: \n${e.toString()}')),
                      );
                    } finally {
                      if (mounted) {
                        Future.microtask(
                          () => setState(() {
                            _loading = false;
                          }),
                        );
                      }
                    }
                  },
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Reject'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: _loading
                ? null
                : () async {
                    print('=== APPROVE BUTTON PRESSED ===');
                    print(
                      'Appointment ID: ${widget.appointment.appointmentId}',
                    );
                    print('Appointment Status: ${widget.appointment.status}');
                    print(
                      'Token: ${Authorization.token != null ? 'Present' : 'Missing'}',
                    );

                    setState(() {
                      _loading = true;
                    });
                    try {
                      final response = await http.put(
                        Uri.parse(
                          'http://localhost:5081/Appointments/${widget.appointment.appointmentId}/approve',
                        ),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer ${Authorization.token}',
                          'accept': 'text/plain',
                        },
                        body: jsonEncode({}),
                      );
                      print('Approve response status: ${response.statusCode}');
                      print('Approve response body: ${response.body}');
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        Navigator.of(context).pop();
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
                              'Failed to approve appointment: \n${response.body}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: \n${e.toString()}')),
                      );
                    } finally {
                      if (mounted) {
                        Future.microtask(
                          () => setState(() {
                            _loading = false;
                          }),
                        );
                      }
                    }
                  },
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Approve'),
          ),
        ],
      ],
    );
  }
}
