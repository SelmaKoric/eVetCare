import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import 'appointment_history_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookAppointmentPage extends StatefulWidget {
  final Appointment? editingAppointment;

  const BookAppointmentPage({super.key, this.editingAppointment});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  int? _selectedPetId;
  String? _selectedPetName;
  List<int> _selectedServiceIds = [];
  List<String> _selectedServiceNames = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = "01:00:00"; // Default 1 hour

  // Data from API
  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _services = [];

  // Duration options
  final List<String> _durationOptions = [
    "00:30:00", // 30 minutes
    "01:00:00", // 1 hour
    "01:30:00", // 1.5 hours
    "02:00:00", // 2 hours
    "02:30:00", // 2.5 hours
    "03:00:00", // 3 hours
  ];

  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([_loadPets(), _loadServices()]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
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

  Future<void> _loadPets() async {
    if (Authorization.userId == null) {
      throw Exception('User ID not found');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5081/Pets?OwnerId=${Authorization.userId}'),
      headers: {
        'Authorization': 'Bearer ${Authorization.token}',
        'Content-Type': 'application/json',
      },
    );

    print('Pets API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      // Handle different response structures
      List<dynamic> petsData;
      if (responseData is List) {
        petsData = responseData;
      } else if (responseData is Map && responseData.containsKey('result')) {
        petsData = responseData['result'] ?? [];
      } else if (responseData is Map &&
          responseData.containsKey('resultList')) {
        petsData = responseData['resultList'] ?? [];
      } else {
        petsData = [];
      }

      setState(() {
        _pets = petsData.cast<Map<String, dynamic>>();
      });

      print('Loaded ${_pets.length} pets');
    } else {
      throw Exception(
        'Failed to load pets: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> _loadServices() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5081/Services'),
      headers: {
        'Authorization': 'Bearer ${Authorization.token}',
        'Content-Type': 'application/json',
      },
    );

    print('Services API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      // Handle different response structures
      List<dynamic> servicesData;
      if (responseData is List) {
        servicesData = responseData;
      } else if (responseData is Map && responseData.containsKey('result')) {
        servicesData = responseData['result'] ?? [];
      } else if (responseData is Map &&
          responseData.containsKey('resultList')) {
        servicesData = responseData['resultList'] ?? [];
      } else {
        servicesData = [];
      }

      setState(() {
        _services = servicesData.cast<Map<String, dynamic>>();
      });

      print('Loaded ${_services.length} services');
    } else {
      throw Exception(
        'Failed to load services: ${response.statusCode} - ${response.body}',
      );
    }
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1].toUpperCase() == 'PM';

      int adjustedHour = hour;
      if (isPM && hour != 12) adjustedHour += 12;
      if (!isPM && hour == 12) adjustedHour = 0;

      return TimeOfDay(hour: adjustedHour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  String _formatDuration(String duration) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: Text(
          widget.editingAppointment != null
              ? "Edit appointment"
              : "New appointment",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.grey[600]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentHistoryPage(),
                ),
              );
            },
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Selection
                    _buildPetDropdown(),
                    const SizedBox(height: 24),

                    // Services Selection
                    _buildServicesDropdown(),
                    const SizedBox(height: 24),

                    // Date Selection
                    _buildDateField(),
                    const SizedBox(height: 24),

                    // Time Selection
                    _buildTimeField(),
                    const SizedBox(height: 24),

                    // Duration Selection
                    _buildDurationField(),
                    const SizedBox(height: 40),

                    // Book Appointment Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            90,
                            183,
                            226,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.editingAppointment != null
                                    ? "Update appointment"
                                    : "Book appointment",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPetDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pet",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedPetId,
              hint: Text(
                "Select a pet",
                style: TextStyle(color: Colors.grey[600]),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: _pets.map((pet) {
                // Handle different field names for pet ID and name
                final petId = pet['id'] ?? pet['petId'];
                final petName = pet['name'] ?? pet['petName'] ?? 'Unknown Pet';

                return DropdownMenuItem<int>(
                  value: petId,
                  child: Text(
                    petName,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                );
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  _selectedPetId = value;
                  final selectedPet = _pets.firstWhere(
                    (pet) => (pet['id'] ?? pet['petId']) == value,
                    orElse: () => {'name': 'Unknown Pet'},
                  );
                  _selectedPetName =
                      selectedPet['name'] ?? selectedPet['petName'];
                });
              },
            ),
          ),
        ),
        if (_formKey.currentState?.validate() == false &&
            _selectedPetId == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a pet',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildServicesDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Services",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Selected services display
              if (_selectedServiceIds.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedServiceIds.map((serviceId) {
                    final service = _services.firstWhere(
                      (s) => (s['id'] ?? s['serviceId']) == serviceId,
                      orElse: () => {'name': 'Unknown Service'},
                    );
                    return Chip(
                      label: Text(
                        service['name'] ??
                            service['serviceName'] ??
                            'Unknown Service',
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedServiceIds.remove(serviceId);
                          final serviceName =
                              service['name'] ?? service['serviceName'];
                          _selectedServiceNames.remove(serviceName);
                        });
                      },
                      backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              // Services dropdown
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  hint: Text(
                    "Select services",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  items: _services
                      .where(
                        (service) => !_selectedServiceIds.contains(
                          service['id'] ?? service['serviceId'],
                        ),
                      )
                      .map((service) {
                        // Handle different field names for service ID and name
                        final serviceId = service['id'] ?? service['serviceId'];
                        final serviceName =
                            service['name'] ??
                            service['serviceName'] ??
                            'Unknown Service';

                        return DropdownMenuItem<int>(
                          value: serviceId,
                          child: Text(
                            serviceName,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        _selectedServiceIds.add(value);
                        final service = _services.firstWhere(
                          (s) => (s['id'] ?? s['serviceId']) == value,
                          orElse: () => {'name': 'Unknown Service'},
                        );
                        final serviceName =
                            service['name'] ?? service['serviceName'];
                        _selectedServiceNames.add(serviceName);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (_formKey.currentState?.validate() == false &&
            _selectedServiceIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least one service',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Duration",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDuration,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: _durationOptions.map((duration) {
                return DropdownMenuItem<String>(
                  value: duration,
                  child: Text(
                    _formatDuration(duration),
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDuration = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                        : "Select date",
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Colors.grey[800]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : "Select time",
                    style: TextStyle(
                      color: _selectedTime != null
                          ? Colors.grey[800]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.access_time, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 90, 183, 226),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 90, 183, 226),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    // Validate form
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Format date and time for API
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointmentData = {
        "petId": _selectedPetId,
        "date": dateTime.toIso8601String(),
        "time":
            "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00",
        "duration": _selectedDuration,
        "serviceIds": _selectedServiceIds,
        "appointmentStatus": 1, // Assuming 1 is for "upcoming" or "scheduled"
        "createdByAdmin": false,
      };

      print('Submitting appointment data: ${json.encode(appointmentData)}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5081/Appointments'),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to home page
          Navigator.pop(context);
        }
      } else {
        throw Exception(
          'Failed to book appointment: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
