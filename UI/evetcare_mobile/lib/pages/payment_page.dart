import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  final int appointmentId;
  final String petName;
  final String serviceNames;
  final String date;
  final String time;
  final double amount;
  final Map<String, dynamic>? invoiceData;

  const PaymentPage({
    super.key,
    required this.appointmentId,
    required this.petName,
    required this.serviceNames,
    required this.date,
    required this.time,
    required this.amount,
    this.invoiceData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;
  String _selectedPaymentMethod = 'Card';

  final List<String> _paymentMethods = ['Card', 'Cash'];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print invoice data if available
    if (widget.invoiceData != null) {
      print('Payment Page - Invoice Data: ${widget.invoiceData}');
    } else {
      print('Payment Page - No invoice data available');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text(
          "Payment",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appointment Summary
              _buildAppointmentSummary(),
              const SizedBox(height: 24),

              // Payment Method Selection
              _buildPaymentMethodSelection(),
              const SizedBox(height: 24),

              // Payment Form
              if (_selectedPaymentMethod == 'Card') ...[
                _buildPaymentForm(),
                const SizedBox(height: 24),
              ],

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
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
                          'Pay \$${widget.amount.toStringAsFixed(2)}',
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

  Widget _buildAppointmentSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Pet', widget.petName),
            _buildSummaryRow('Services', widget.serviceNames),
            _buildSummaryRow('Date', widget.date),
            _buildSummaryRow('Time', widget.time),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              '\$${widget.amount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal
                  ? const Color.fromARGB(255, 90, 183, 226)
                  : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method",
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
              value: _selectedPaymentMethod,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(
                    method,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),

        // Card Number
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.replaceAll(' ', '').length < 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Name on Card
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name on Card',
            hintText: 'John Doe',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter name on card';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Expiry and CVV Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.grey[600],
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return 'Please enter in MM/YY format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.security, color: Colors.grey[600]),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CVV';
                  }
                  if (value.length < 3) {
                    return 'Please enter a valid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    // Only validate form if Card payment is selected
    if (_selectedPaymentMethod == 'Card') {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Call payment API
      final paymentData = {
        "appointmentId": widget.appointmentId,
        "amount": widget.amount,
        "paymentMethod": _selectedPaymentMethod,
        "status": "completed",
        "transactionDate": DateTime.now().toIso8601String(),
      };

      print('Processing payment: ${json.encode(paymentData)}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5081/Payments'),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to home page
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        throw Exception(
          'Payment failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
