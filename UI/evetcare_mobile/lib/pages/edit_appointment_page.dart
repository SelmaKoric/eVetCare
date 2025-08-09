import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentPage({super.key, required this.appointment});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  int? _selectedPetId;
  String? _selectedPetName;
  List<int> _selectedServiceIds = [];
  List<String> _selectedServiceNames = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = "01:00:00";

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
    _initializeData();
    _loadData();
  }

  void _initializeData() {
    final appointment = widget.appointment;
    _selectedPetId = appointment.petId;
    _selectedPetName = appointment.petName;
    // We'll set the service IDs after loading the services from API
    _selectedServiceNames = appointment.serviceNames
        .map((service) => service.name)
        .toList();

    // Parse date and time
    try {
      final dateParts = appointment.date.split('-');
      if (dateParts.length == 3) {
        _selectedDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    try {
      final timeParts = appointment.time.split(':');
      if (timeParts.length >= 2) {
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    } catch (e) {
      print('Error parsing time: $e');
    }

    _selectedDuration = appointment.duration;
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
    final pets = await AppointmentService.getPets();
    setState(() {
      _pets = pets;
    });
  }

  Future<void> _loadServices() async {
    final services = await AppointmentService.getServices();
    setState(() {
      _services = services;
    });

    // Match service names with their IDs
    _matchServiceNamesWithIds();
  }

  void _matchServiceNamesWithIds() {
    final List<int> matchedIds = [];

    for (String serviceName in _selectedServiceNames) {
      final service = _services.firstWhere(
        (s) => (s['name'] ?? '').toLowerCase() == serviceName.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );

      if (service.isNotEmpty) {
        final serviceId = service['serviceId'] ?? service['id'];
        if (serviceId != null) {
          matchedIds.add(serviceId);
        }
      }
    }

    setState(() {
      _selectedServiceIds = matchedIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text(
          "Edit Appointment",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
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

                    // Update Appointment Button
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
                            : const Text(
                                "Update Appointment",
                                style: TextStyle(
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
                final petId = pet['petId'] ?? pet['id'];
                final petName = pet['name'] ?? 'Unknown Pet';

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
                    (pet) => (pet['petId'] ?? pet['id']) == value,
                    orElse: () => {'name': 'Unknown Pet'},
                  );
                  _selectedPetName = selectedPet['name'];
                });
              },
            ),
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
              if (_selectedServiceIds.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedServiceIds.asMap().entries.map((entry) {
                    final index = entry.key;
                    final serviceId = entry.value;
                    final serviceName = index < _selectedServiceNames.length
                        ? _selectedServiceNames[index]
                        : 'Unknown Service';

                    return Chip(
                      label: Text(serviceName),
                      onDeleted: () {
                        setState(() {
                          _selectedServiceIds.removeAt(index);
                          _selectedServiceNames.removeAt(index);
                        });
                      },
                      backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
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
                        (service) =>
                            !_selectedServiceNames.contains(service['name']),
                      )
                      .map((service) {
                        final serviceId = service['serviceId'] ?? service['id'];
                        final serviceName =
                            service['name'] ?? 'Unknown Service';

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
                        final service = _services.firstWhere(
                          (s) => (s['serviceId'] ?? s['id']) == value,
                          orElse: () => <String, dynamic>{},
                        );
                        if (service.isNotEmpty) {
                          _selectedServiceIds.add(value);
                          _selectedServiceNames.add(
                            service['name'] ?? 'Unknown Service',
                          );
                        }
                      });
                    }
                  },
                ),
              ),
            ],
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
                    AppointmentService.formatDuration(duration),
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
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    // Validate form using service
    final validationError = AppointmentService.validateAppointmentData(
      petId: _selectedPetId,
      serviceIds: _selectedServiceIds,
      date: _selectedDate,
      time: _selectedTime,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare appointment data using service
      final appointmentData = AppointmentService.prepareAppointmentData(
        petId: _selectedPetId!,
        date: _selectedDate!,
        time: _selectedTime!,
        duration: _selectedDuration,
        serviceIds: _selectedServiceIds,
      );

      await AppointmentService.updateAppointment(
        widget.appointment.appointmentId,
        appointmentData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment: $e'),
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
