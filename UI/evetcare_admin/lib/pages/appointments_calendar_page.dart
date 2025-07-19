import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';

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
          description: "Owner: ${appt.ownerName}\nStatus: ${appt.status}",
          color: appt.status == 'Completed' ? Colors.green : Colors.blue,
        ),
      );
    }
    _eventsAddedForDate = true;
    _lastMappedAppointments = appointments;
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
