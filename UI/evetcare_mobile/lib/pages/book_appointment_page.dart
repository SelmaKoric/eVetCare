import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'appointment_history_page.dart';
import 'payment_page.dart';

class BookAppointmentPage extends StatefulWidget {
  final Appointment? editingAppointment;

  const BookAppointmentPage({super.key, this.editingAppointment});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedPetId;
  String? _selectedPetName;
  List<int> _selectedServiceIds = [];
  List<String> _selectedServiceNames = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = "01:00:00"; 

  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _services = [];

  final List<String> _durationOptions = [
    "00:30:00", 
    "01:00:00",
    "01:30:00", 
    "02:00:00", 
    "02:30:00", 
    "03:00:00", 
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
    final pets = await AppointmentService.getPets();
    setState(() {
      _pets = pets;
    });
    print('Loaded ${_pets.length} pets');
  }

  Future<void> _loadServices() async {
    final services = await AppointmentService.getServices();
    setState(() {
      _services = services;
    });
    print('Loaded ${_services.length} services');
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
                    _buildPetDropdown(),
                    const SizedBox(height: 24),

                    _buildServicesDropdown(),
                    const SizedBox(height: 24),

                    _buildDateField(),
                    const SizedBox(height: 24),

                    _buildTimeField(),
                    const SizedBox(height: 24),

                    _buildDurationField(),
                    const SizedBox(height: 40),

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
                        ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
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
      final appointmentData = AppointmentService.prepareAppointmentData(
        petId: _selectedPetId!,
        date: _selectedDate!,
        time: _selectedTime!,
        duration: _selectedDuration,
        serviceIds: _selectedServiceIds,
      );

      print('Submitting appointment data: $appointmentData');

      final response = await AppointmentService.createAppointment(
        appointmentData,
      );

      if (mounted) {
        final appointmentId = response['appointmentId'] ?? response['id'] ?? 0;

        _showPaymentModal(appointmentId);
      }
    } catch (e) {
      if (mounted) {
        final errorInfo = AppointmentService.handleAppointmentError(e);
        final errorMessage = errorInfo['message'] as String;
        final isOverlapError = errorInfo['isOverlapError'] as bool;

        if (isOverlapError) {
          _showOverlapErrorDialog(errorMessage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showPaymentModal(int appointmentId) {
    print('Creating invoice with service IDs: $_selectedServiceIds');
    print('Selected service names: $_selectedServiceNames');

    _createInvoice(appointmentId).then((invoiceData) {
      if (invoiceData != null) {
        double actualAmount = _getActualAmountFromInvoice(invoiceData);
        print('Actual amount from invoice: $actualAmount');

        _showPaymentDialog(appointmentId, actualAmount, invoiceData);
      } else {
        double estimatedAmount = _calculateEstimatedAmount();
        _showPaymentDialog(appointmentId, estimatedAmount, null);
      }
    });
  }

  void _showPaymentDialog(
    int appointmentId,
    double amount,
    Map<String, dynamic>? invoiceData,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.payment,
                color: const Color.fromARGB(255, 90, 183, 226),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your appointment has been booked successfully!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceData != null
                          ? 'Total Amount:'
                          : 'Estimated Amount:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 90, 183, 226),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Would you like to pay now or later?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Appointment booked successfully! You can pay later.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Pay Later',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      appointmentId: appointmentId,
                      petName: _selectedPetName ?? 'Unknown Pet',
                      serviceNames: _selectedServiceNames.join(', '),
                      date: _selectedDate != null
                          ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                          : 'Unknown Date',
                      time: _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Unknown Time',
                      amount: amount,
                      invoiceData: invoiceData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateEstimatedAmount() {
    // Base amount for appointment
    double baseAmount = 50.0;

    double serviceAmount = _selectedServiceIds.length * 25.0;

    double durationAmount = 0.0;
    switch (_selectedDuration) {
      case "00:30:00":
        durationAmount = 0.0; 
        break;
      case "01:00:00":
        durationAmount = 10.0; 
        break;
      case "01:30:00":
        durationAmount = 20.0; 
        break;
      case "02:00:00":
        durationAmount = 30.0; 
        break;
      case "02:30:00":
        durationAmount = 40.0;
        break;
      case "03:00:00":
        durationAmount = 50.0;
        break;
    }

    return baseAmount + serviceAmount + durationAmount;
  }

  double _getActualAmountFromInvoice(Map<String, dynamic> invoiceData) {
    try {
      double amount = 0.0;

      if (invoiceData.containsKey('totalAmount')) {
        amount = (invoiceData['totalAmount'] as num).toDouble();
      } else if (invoiceData.containsKey('amount')) {
        amount = (invoiceData['amount'] as num).toDouble();
      } else if (invoiceData.containsKey('total')) {
        amount = (invoiceData['total'] as num).toDouble();
      } else if (invoiceData.containsKey('grandTotal')) {
        amount = (invoiceData['grandTotal'] as num).toDouble();
      } else if (invoiceData.containsKey('invoiceTotal')) {
        amount = (invoiceData['invoiceTotal'] as num).toDouble();
      } else {
        amount = _calculateAmountFromLineItems(invoiceData);
      }

      print('Extracted amount from invoice: $amount');
      return amount;
    } catch (e) {
      print('Error extracting amount from invoice: $e');
      return _calculateEstimatedAmount();
    }
  }

  double _calculateAmountFromLineItems(Map<String, dynamic> invoiceData) {
    try {
      double total = 0.0;

      List<dynamic> lineItems = [];

      if (invoiceData.containsKey('lineItems')) {
        lineItems = invoiceData['lineItems'] as List<dynamic>;
      } else if (invoiceData.containsKey('items')) {
        lineItems = invoiceData['items'] as List<dynamic>;
      } else if (invoiceData.containsKey('services')) {
        lineItems = invoiceData['services'] as List<dynamic>;
      } else if (invoiceData.containsKey('invoiceItems')) {
        lineItems = invoiceData['invoiceItems'] as List<dynamic>;
      }

      for (var item in lineItems) {
        if (item is Map<String, dynamic>) {
          double price = 0.0;
          int quantity = 1;

          if (item.containsKey('price')) {
            price = (item['price'] as num).toDouble();
          } else if (item.containsKey('amount')) {
            price = (item['amount'] as num).toDouble();
          } else if (item.containsKey('cost')) {
            price = (item['cost'] as num).toDouble();
          }

          if (item.containsKey('quantity')) {
            quantity = (item['quantity'] as num).toInt();
          } else if (item.containsKey('qty')) {
            quantity = (item['qty'] as num).toInt();
          }

          total += price * quantity;
        }
      }

      print('Calculated total from line items: $total');
      return total;
    } catch (e) {
      print('Error calculating amount from line items: $e');
      return 0.0;
    }
  }

  Future<Map<String, dynamic>?> _createInvoice(int appointmentId) async {
    try {
      print('_createInvoice called with appointmentId: $appointmentId');
      print('Current _selectedServiceIds: $_selectedServiceIds');
      print('Current _selectedServiceNames: $_selectedServiceNames');

      final invoiceData = {
        "appointmentId": appointmentId,
        "serviceIds": _selectedServiceIds,
        "issueDate": DateTime.now().toIso8601String(),
      };

      print('Creating invoice with data: $invoiceData');

      final response = await AppointmentService.createInvoice(invoiceData);

      print('Invoice created successfully: $response');
      print('Invoice response type: ${response.runtimeType}');
      print('Invoice response keys: ${response.keys.toList()}');

      return response;
    } catch (e) {
      print('Error creating invoice: $e');
      return null;
    }
  }

  void _showOverlapErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Text('Time Slot Unavailable'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please select a different date or time for your appointment.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
