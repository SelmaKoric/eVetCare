import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/search_result.dart';
import '../providers/invoice_provider.dart';
import '../models/service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/authorization.dart';
import '../models/payment.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_provider.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late InvoiceProvider _invoiceProvider;
  late Future<SearchResult<Invoice>> _futureInvoices;
  Map<int, String> _serviceNames = {}; // serviceId -> name
  bool _loadingServices = false;
  Map<int, List<Payment>> _payments = {}; // invoiceId -> List<Payment>
  bool _loadingPayments = false;

  @override
  void initState() {
    super.initState();
    _invoiceProvider = InvoiceProvider();
    fetchInvoices();
  }

  void fetchInvoices() {
    setState(() {
      _futureInvoices = _invoiceProvider.get();
      // Clear cached data to force refresh
      _serviceNames.clear();
      _payments.clear();
      _loadingServices = false;
      _loadingPayments = false;
    });
  }

  Future<void> _fetchServiceNamesForInvoices(List<Invoice> invoices) async {
    setState(() {
      _loadingServices = true;
    });
    final serviceIds = invoices
        .expand((inv) => inv.invoiceItems.map((item) => item.serviceId))
        .toSet();
    final Map<int, String> names = {};
    for (final id in serviceIds) {
      try {
        final headers = {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
          if (Authorization.token != null)
            'Authorization': 'Bearer ${Authorization.token}',
        };
        final response = await http.get(
          Uri.parse('http://localhost:5081/Services/$id'),
          headers: headers,
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          try {
            final service = Service.fromJson(data);
            names[id] = service.name;
          } catch (e) {
            names[id] = 'Unknown';
          }
        } else {
          names[id] = 'Unknown';
        }
      } catch (e) {
        names[id] = 'Unknown';
      }
    }
    setState(() {
      _serviceNames = names;
      _loadingServices = false;
    });
  }

  Future<void> _fetchPaymentsForInvoices(List<Invoice> invoices) async {
    setState(() {
      _loadingPayments = true;
    });
    final Map<int, List<Payment>> paymentsMap = {};
    for (final invoice in invoices) {
      try {
        final headers = {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
          if (Authorization.token != null)
            'Authorization': 'Bearer ${Authorization.token}',
        };
        print('Fetching payments for invoice ${invoice.invoiceId}');
        final response = await http.get(
          Uri.parse(
            'http://localhost:5081/Payment?invoiceId=${invoice.invoiceId}',
          ),
          headers: headers,
        );
        print('Payment API response status: ${response.statusCode}');
        print('Payment API response body: ${response.body}');
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          print('Decoded payment data: $data');
          final List<dynamic> result =
              data is Map<String, dynamic> && data.containsKey('result')
              ? data['result']
              : data;
          print('Payment result list: $result');

          // Filter payments that actually belong to this invoice
          final List<Payment> invoicePayments = [];
          for (final paymentJson in result) {
            final payment = Payment.fromJson(
              paymentJson as Map<String, dynamic>,
            );
            if (payment.invoiceId == invoice.invoiceId) {
              invoicePayments.add(payment);
            }
          }

          paymentsMap[invoice.invoiceId] = invoicePayments;
          print(
            'Parsed payments for invoice ${invoice.invoiceId}: ${paymentsMap[invoice.invoiceId]}',
          );
        } else {
          print(
            'Payment API error for invoice ${invoice.invoiceId}: ${response.statusCode}',
          );
          paymentsMap[invoice.invoiceId] = [];
        }
      } catch (e) {
        print(
          'Exception fetching payments for invoice ${invoice.invoiceId}: $e',
        );
        paymentsMap[invoice.invoiceId] = [];
      }
    }
    print('Final payments map: $_payments');
    setState(() {
      _payments = paymentsMap;
      _loadingPayments = false;
    });
  }

  void _showAddInvoiceModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddInvoiceDialog(onInvoiceCreated: fetchInvoices);
      },
    );
  }

  void _showPaymentModal(Invoice invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PaymentModal(
          invoice: invoice,
          onPaymentAdded: () {
            fetchInvoices();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _InvoiceDetailsModal(invoice: invoice);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _invoiceProvider,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoices',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddInvoiceModal,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<SearchResult<Invoice>>(
                future: _futureInvoices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \n${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.result.isEmpty) {
                    return const Center(child: Text('No invoices found.'));
                  }
                  final invoices = snapshot.data!.result;
                  // Fetch service names if not already loaded
                  if (_serviceNames.isEmpty && !_loadingServices) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _fetchServiceNamesForInvoices(invoices);
                    });
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Fetch payments if not already loaded
                  if (_payments.isEmpty && !_loadingPayments) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _fetchPaymentsForInvoices(invoices);
                    });
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Invoice ID')),
                      DataColumn(label: Text('Total Amount')),
                      DataColumn(label: Text('Issue Date')),
                      DataColumn(label: Text('Services')),
                      DataColumn(label: Text('Amount Paid')),
                      DataColumn(label: Text('Date Paid')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: invoices.map((invoice) {
                      final serviceNames = invoice.invoiceItems
                          .map((item) => _serviceNames[item.serviceId])
                          .where(
                            (name) =>
                                name != null &&
                                name != 'Unknown' &&
                                name!.isNotEmpty,
                          )
                          .join(', ');
                      final payments = _payments[invoice.invoiceId] ?? [];
                      print('Building row for invoice ${invoice.invoiceId}');
                      print(
                        'Payments for this invoice: ${payments.map((p) => p.toJson())}',
                      );
                      final amountPaid = payments.fold<double>(
                        0.0,
                        (sum, p) => sum + p.amount,
                      );
                      print('Calculated amount paid: $amountPaid');
                      final datePaid = payments.isNotEmpty
                          ? payments
                                .map((p) {
                                  final dateParts = p.paymentDate
                                      .split('T')
                                      .first
                                      .split('-');
                                  return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
                                })
                                .join(', ')
                          : '—';
                      print('Calculated date paid: $datePaid');
                      final isPaid =
                          amountPaid >= invoice.totalAmount && amountPaid > 0;
                      print('Invoice ${invoice.invoiceId} isPaid: $isPaid');
                      return DataRow(
                        cells: [
                          DataCell(Text(invoice.invoiceId.toString())),
                          DataCell(
                            Text(invoice.totalAmount.toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(() {
                              final dateParts = invoice.issueDate
                                  .split('T')
                                  .first
                                  .split('-');
                              return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
                            }()),
                          ),
                          DataCell(
                            Text(serviceNames.isNotEmpty ? serviceNames : '—'),
                          ),
                          DataCell(
                            Text(
                              amountPaid > 0
                                  ? amountPaid.toStringAsFixed(2)
                                  : '—',
                            ),
                          ),
                          DataCell(Text(datePaid)),
                          DataCell(
                            payments.isNotEmpty
                                ? Chip(
                                    label: Text(isPaid ? 'Paid' : 'Unpaid'),
                                    backgroundColor: isPaid
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    labelStyle: TextStyle(
                                      color: isPaid
                                          ? Colors.green[900]
                                          : Colors.red[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Chip(
                                    label: const Text('Unpaid'),
                                    backgroundColor: Colors.red[100],
                                    labelStyle: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isPaid)
                                  IconButton(
                                    onPressed: () => _showPaymentModal(invoice),
                                    icon: const Icon(
                                      Icons.payment,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    tooltip: 'Mark as Paid',
                                  ),
                                IconButton(
                                  onPressed: () => _showInvoiceDetails(invoice),
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  tooltip: 'View Details',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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

class _AddInvoiceDialog extends StatefulWidget {
  final VoidCallback onInvoiceCreated;

  const _AddInvoiceDialog({required this.onInvoiceCreated});

  @override
  State<_AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<_AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  Appointment? _selectedAppointment;
  final List<int> _selectedServiceIds = [];

  List<Appointment> _appointments = [];
  List<Service> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
    });
    try {
      // Fetch appointments - get all appointments
      final appointmentProvider = AppointmentProvider();
      await appointmentProvider.fetchAllAppointments();
      _appointments = appointmentProvider.appointments;

      // Fetch services
      final serviceProvider = ServiceProvider();
      final servicesResult = await serviceProvider.get();
      _services = servicesResult.result;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
        _loading = false;
      });
    }
  }

  double get _totalPrice {
    double total = 0.0;
    for (final serviceId in _selectedServiceIds) {
      final service = _services.firstWhere(
        (s) => s.serviceId == serviceId,
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
      total += service.price ?? 0.0;
    }
    return total;
  }

  Future<void> _createInvoice() async {
    if (_selectedAppointment == null || _selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an appointment and at least one service',
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final invoiceData = {
        'appointmentId': _selectedAppointment!.appointmentId,
        'totalAmount': _totalPrice,
        'issueDate': DateTime.now().toIso8601String(),
        'serviceIds': _selectedServiceIds,
      };

      print('Creating invoice with data: $invoiceData');

      final response = await http.post(
        Uri.parse('http://localhost:5081/Invoice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
        body: jsonEncode(invoiceData),
      );

      print('Invoice creation response status: ${response.statusCode}');
      print('Invoice creation response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully!')),
        );
        // Refresh the invoice list
        widget.onInvoiceCreated();
        // Show refresh indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing invoice list...'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create invoice: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating invoice: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Invoice'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: _loading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
            ? SizedBox(height: 200, child: Center(child: Text(_error!)))
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appointment Selection
                      const Text(
                        'Select Appointment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Appointment>(
                        value: _selectedAppointment,
                        decoration: const InputDecoration(
                          labelText: 'Appointment',
                          border: OutlineInputBorder(),
                        ),
                        items: _appointments.map((appointment) {
                          return DropdownMenuItem<Appointment>(
                            value: appointment,
                            child: Text(
                              '${appointment.petName} (${appointment.ownerName}) - ${(() {
                                final dateParts = appointment.date.split('T').first.split('-');
                                return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
                              }())} ${appointment.time}',
                            ),
                          );
                        }).toList(),
                        onChanged: (appointment) {
                          setState(() {
                            _selectedAppointment = appointment;
                            // Auto-select services from the appointment
                            if (appointment != null) {
                              _selectedServiceIds.clear();
                              for (final serviceName
                                  in appointment.serviceNames) {
                                final service = _services.firstWhere(
                                  (s) => s.name == serviceName.name,
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
                                if (service.serviceId != -1) {
                                  _selectedServiceIds.add(service.serviceId);
                                }
                              }
                            }
                          });
                        },
                        validator: (value) => value == null
                            ? 'Please select an appointment'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Services Selection
                      const Text(
                        'Select Services',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _services.map((service) {
                              final isSelected = _selectedServiceIds.contains(
                                service.serviceId,
                              );
                              return CheckboxListTile(
                                title: Text(service.name),
                                subtitle: Text(
                                  '${service.description} - \$${(service.price ?? 0.0).toStringAsFixed(2)}',
                                ),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedServiceIds.add(
                                        service.serviceId,
                                      );
                                    } else {
                                      _selectedServiceIds.remove(
                                        service.serviceId,
                                      );
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total Price Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Price:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${_totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
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
          onPressed: _loading ? null : _createInvoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Invoice'),
        ),
      ],
    );
  }
}

class _PaymentModal extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onPaymentAdded;

  const _PaymentModal({required this.invoice, required this.onPaymentAdded});

  @override
  State<_PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<_PaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentData = {
        'invoiceId': widget.invoice.invoiceId,
        'amount': double.parse(_amountController.text),
        'methodId': _selectedPaymentMethod == 'Cash' ? 1 : 2,
        'paymentDate': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('http://localhost:5081/Payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onPaymentAdded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording payment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.payment, color: Colors.green),
          const SizedBox(width: 8),
          Text('Record Payment - Invoice #${widget.invoice.invoiceId}'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Total: \$${widget.invoice.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Issue Date: ${(() {
                          final dateParts = widget.invoice.issueDate.split('T').first.split('-');
                          return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
                        }())}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter payment amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Payment Method
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
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
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitPayment,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.payment),
          label: Text(_isLoading ? 'Processing...' : 'Record Payment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _InvoiceDetailsModal extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceDetailsModal({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.receipt, color: Colors.blue),
          const SizedBox(width: 8),
          Text('Invoice Details - #${invoice.invoiceId}'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice #${invoice.invoiceId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Issue Date: ${(() {
                        final dateParts = invoice.issueDate.split('T').first.split('-');
                        return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
                      }())}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Invoice Items
              const Text(
                'Services',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...invoice.invoiceItems.map(
                (item) => Card(
                  child: ListTile(
                    title: Text('Service ID: ${item.serviceId}'),
                    subtitle: Text('Invoice Item ID: ${item.invoiceItemId}'),
                    trailing: const Icon(
                      Icons.medical_services,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
