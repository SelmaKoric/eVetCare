import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import '../core/stripe_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _isProcessing = false;

  // Saved payment details
  String _savedCardNumber = '';
  String _savedExpiry = '';
  String _savedCvv = '';
  String _savedName = '';
  String _savedZip = '';
  bool _savePaymentDetails = true;

  // Controllers for text fields
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  late TextEditingController _nameController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSavedPaymentDetails();
  }

  void _initializeControllers() {
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
    _nameController = TextEditingController();
    _zipController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              // Payment Form
              _buildPaymentForm(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Load saved payment details from shared preferences
  Future<void> _loadSavedPaymentDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedCardNumber = prefs.getString('saved_card_number') ?? '';
        _savedExpiry = prefs.getString('saved_expiry') ?? '';
        _savedCvv = prefs.getString('saved_cvv') ?? '';
        _savedName = prefs.getString('saved_name') ?? '';
        _savedZip = prefs.getString('saved_zip') ?? '';
        _savePaymentDetails = prefs.getBool('save_payment_details') ?? true;
      });

      // Populate controllers with saved data
      _cardNumberController.text = _savedCardNumber;
      _expiryController.text = _savedExpiry;
      _cvvController.text = _savedCvv;
      _nameController.text = _savedName;
      _zipController.text = _savedZip;

      print('Loaded saved payment details:');
      print(
        'Card Number: ${_savedCardNumber.isNotEmpty ? "${_savedCardNumber.substring(0, 4)}****" : "Not saved"}',
      );
      print('Expiry: $_savedExpiry');
      print('CVV: ${_savedCvv.isNotEmpty ? "***" : "Not saved"}');
      print('Name: $_savedName');
      print('ZIP: $_savedZip');
    } catch (e) {
      print('Error loading saved payment details: $e');
    }
  }

  // Save payment details to shared preferences
  Future<void> _savePaymentDetailsToStorage() async {
    try {
      print('Saving payment details to storage...');
      final prefs = await SharedPreferences.getInstance();
      if (_savePaymentDetails) {
        await prefs.setString('saved_card_number', _savedCardNumber);
        await prefs.setString('saved_expiry', _savedExpiry);
        await prefs.setString('saved_cvv', _savedCvv);
        await prefs.setString('saved_name', _savedName);
        await prefs.setString('saved_zip', _savedZip);
        await prefs.setBool('save_payment_details', _savePaymentDetails);
        print('Payment details saved successfully');
      } else {
        // Clear saved details if user doesn't want to save
        await prefs.remove('saved_card_number');
        await prefs.remove('saved_expiry');
        await prefs.remove('saved_cvv');
        await prefs.remove('saved_name');
        await prefs.remove('saved_zip');
        await prefs.setBool('save_payment_details', false);
        print('Payment details cleared from storage');
      }
    } catch (e) {
      print('Error saving payment details: $e');
    }
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

        // Stripe Payment Button
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _handleStripePayment,
            icon: Icon(Icons.payment, color: Colors.white),
            label: Text(
              'Enter Payment Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 90, 183, 226),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Payment Details Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: _savedCardNumber.isEmpty
                      ? '4242 4242 4242 4242'
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
                ),
                onChanged: (value) {
                  setState(() {
                    _savedCardNumber = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Expiry and CVV Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        hintText: _savedExpiry.isEmpty ? '12/25' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _savedExpiry = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: _savedCvv.isEmpty ? '123' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _savedCvv = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Name on Card
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name on Card',
                  hintText: _savedName.isEmpty ? 'John Doe' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                ),
                onChanged: (value) {
                  setState(() {
                    _savedName = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              // ZIP Code
              TextFormField(
                controller: _zipController,
                decoration: InputDecoration(
                  labelText: 'ZIP Code',
                  hintText: _savedZip.isEmpty ? '12345' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey[600]),
                ),
                onChanged: (value) {
                  setState(() {
                    _savedZip = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Save Payment Details Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _savePaymentDetails,
                    onChanged: (value) {
                      setState(() {
                        _savePaymentDetails = value ?? true;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 90, 183, 226),
                  ),
                  Expanded(
                    child: Text(
                      'Save payment details for future use',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),

              // Test Card Info
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Test Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use test card: 4242 4242 4242 4242',
                      style: TextStyle(fontSize: 11, color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your payment details will be securely handled by Stripe',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    await _handleStripePayment();
  }

  Future<void> _handleCashPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Call payment API for cash payment
      final paymentData = {
        "appointmentId": widget.appointmentId,
        "amount": widget.amount,
        "paymentMethod": "Cash",
        "status": "completed",
        "transactionDate": DateTime.now().toIso8601String(),
      };

      print('Processing cash payment: ${json.encode(paymentData)}');

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
              content: Text('Cash payment completed successfully!'),
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

  Future<void> _handleStripePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      print('=== STRIPE PAYMENT API CALL START ===');
      print('Appointment ID: ${widget.appointmentId}');
      print('Amount: \$${widget.amount}');
      print('Invoice Data: ${widget.invoiceData}');

      // Get the invoice ID from the invoice data
      int? invoiceId;

      if (widget.invoiceData != null) {
        // Try to extract invoice ID from the invoice data
        if (widget.invoiceData!.containsKey('id')) {
          invoiceId = widget.invoiceData!['id'] as int;
        } else if (widget.invoiceData!.containsKey('invoiceId')) {
          invoiceId = widget.invoiceData!['invoiceId'] as int;
        } else if (widget.invoiceData!.containsKey('invoice_id')) {
          invoiceId = widget.invoiceData!['invoice_id'] as int;
        }
      }

      if (invoiceId == null) {
        throw Exception(
          'Invoice ID not found. Please try creating the appointment again.',
        );
      }

      print('Extracted Invoice ID: $invoiceId');
      print('API URL: ${StripeConfig.apiUrl}/Payment/create-intent/$invoiceId');
      print(
        'Request Body: ${json.encode({
          'amount': (widget.amount * 100).round(), // Convert to cents
          'currency': 'usd',
        })}',
      );

      // Get client secret directly using invoice ID
      final clientSecretResponse = await http.post(
        Uri.parse('${StripeConfig.apiUrl}/Payment/create-intent/$invoiceId'),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': (widget.amount * 100).round(), // Convert to cents
          'currency': 'usd',
        }),
      );

      print('Response Status Code: ${clientSecretResponse.statusCode}');
      print('Response Headers: ${clientSecretResponse.headers}');
      print('Response Body: ${clientSecretResponse.body}');

      if (clientSecretResponse.statusCode == 404) {
        print('ERROR: Payment endpoint not found (404)');
        throw Exception(
          'Payment endpoint not found. Please check if the backend server is running and the payment endpoint is configured correctly.',
        );
      }

      if (clientSecretResponse.statusCode != 200) {
        print(
          'ERROR: Payment intent creation failed with status ${clientSecretResponse.statusCode}',
        );
        throw Exception(
          'Failed to get payment intent: ${clientSecretResponse.statusCode} - ${clientSecretResponse.body}',
        );
      }

      final clientSecretData = json.decode(clientSecretResponse.body);
      print('Parsed Response Data: $clientSecretData');

      final clientSecret = clientSecretData['clientSecret'];
      print(
        'Extracted Client Secret: ${clientSecret != null ? "***SECRET***" : "NULL"}',
      );

      if (clientSecret == null) {
        print('ERROR: Client secret not received from server');
        throw Exception('Client secret not received from server');
      }

      print('Configuring Stripe payment sheet...');
      // Configure payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'eVetCare',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color.fromARGB(255, 90, 183, 226),
            ),
          ),
        ),
      );

      print('Presenting Stripe payment sheet...');
      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      print('Payment sheet completed successfully');

      // If we reach here, payment was successful
      if (mounted) {
        print('Payment completed successfully!');
        print('Saving payment details...');

        // Save payment details if user opted to save them
        await _savePaymentDetailsToStorage();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home page
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on StripeException catch (e) {
      print('STRIPE EXCEPTION: ${e.error.code} - ${e.error.message}');
      if (mounted) {
        String errorMessage = 'Payment failed';

        if (e.error.code == 'failed') {
          errorMessage = 'Payment failed. Please try again.';
        } else if (e.error.code == 'canceled') {
          errorMessage = 'Payment was canceled.';
        } else {
          errorMessage =
              e.error.localizedMessage ?? e.error.message ?? 'Payment failed';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('GENERAL EXCEPTION: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('=== STRIPE PAYMENT API CALL END ===');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
