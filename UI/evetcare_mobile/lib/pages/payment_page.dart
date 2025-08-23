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
  bool _cardFormComplete = false;
  bool _stripeInitialized = false;

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    try {
      _initializeControllers();
      _loadSavedPaymentDetails();
      _initializeStripe();
    } catch (e) {
      print('Error in PaymentPage initState: $e');
    }
  }

  Future<void> _initializeStripe() async {
    try {
      // Ensure Stripe is properly initialized
      await Stripe.instance.applySettings();
      setState(() {
        _stripeInitialized = true;
      });
      print('Stripe initialized successfully in PaymentPage');
    } catch (e) {
      print('Error initializing Stripe in PaymentPage: $e');
      setState(() {
        _stripeInitialized = false;
      });
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _zipController = TextEditingController();
  }

  @override
  void dispose() {
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

              // Payment Button - Now below the form
              _buildPaymentButton(),
              const SizedBox(height: 16),

              // Info text
              _buildInfoText(),
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

      // Populate controllers with saved data or test data
      _nameController.text = prefs.getString('saved_name') ?? 'John Doe';
      _zipController.text = prefs.getString('saved_zip') ?? '12345';

      print('Loaded payment details:');
      print('Name: ${_nameController.text}');
      print('ZIP: ${_zipController.text}');
    } catch (e) {
      print('Error loading saved payment details: $e');
      // Set test data as fallback
      _nameController.text = 'John Doe';
      _zipController.text = '12345';
    }
  }

  // Save payment details to shared preferences
  Future<void> _savePaymentDetailsToStorage() async {
    try {
      print('Saving payment details to storage...');
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('saved_name', _nameController.text);
      await prefs.setString('saved_zip', _zipController.text);

      print('Payment details saved successfully');
    } catch (e) {
      print('Error saving payment details: $e');
    }
  }

  // Show payment success dialog
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your payment of \$${widget.amount.toStringAsFixed(2)} has been processed successfully.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Pet: ${widget.petName}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Services: ${widget.serviceNames}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Date: ${widget.date} at ${widget.time}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ); // Go to home
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 90, 183, 226),
                ),
              ),
            ),
          ],
        );
      },
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

  Widget _buildPaymentForm() {
    if (!_stripeInitialized) {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 90, 183, 226),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing payment system...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

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
                    'Card Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stripe Card Form Field
              CardFormField(
                style: CardFormStyle(
                  borderColor: Colors.grey[300]!,
                  borderRadius: 8,
                  fontSize: 16,
                  placeholderColor: Colors.grey[400]!,
                  textColor: Colors.grey[800]!,
                ),
                onCardChanged: (card) {
                  setState(() {
                    _cardFormComplete = card?.complete ?? false;
                  });
                  print(
                    'Card form changed - Complete: ${card?.complete ?? false}',
                  );
                },
              ),
              const SizedBox(height: 16),

              // Name on Card
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name on Card',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 12),

              // ZIP Code
              TextFormField(
                controller: _zipController,
                decoration: InputDecoration(
                  labelText: 'ZIP Code',
                  hintText: '12345',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 16),

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
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: (_isProcessing || !_cardFormComplete || !_stripeInitialized)
            ? null
            : _handleStripePayment,
        icon: Icon(Icons.payment, color: Colors.white),
        label: Text(
          _isProcessing ? 'Processing Payment...' : 'Pay Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 90, 183, 226),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
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
    );
  }

  Future<void> _handleStripePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Validate Stripe configuration first
      if (!StripeConfig.publishableKey.startsWith('pk_test_') &&
          !StripeConfig.publishableKey.startsWith('pk_live_')) {
        throw Exception(
          'Invalid Stripe API key configuration. Please check your Stripe setup.',
        );
      }

      print('=== STRIPE PAYMENT API CALL START ===');
      print('Appointment ID: ${widget.appointmentId}');
      print('Amount: \$${widget.amount}');
      print('Invoice Data: ${widget.invoiceData}');
      print('Stripe Key: ${StripeConfig.publishableKey.substring(0, 10)}...');

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

      print('Processing payment with Stripe card form...');

      // Create payment method using the card form data
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text,
              address: Address(
                line1: '',
                line2: '',
                city: '',
                state: '',
                country: '',
                postalCode: _zipController.text,
              ),
            ),
          ),
        ),
      );

      print('Payment method created: ${paymentMethod.id}');

      // Confirm payment with the client secret
      final paymentResult = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text,
              address: Address(
                line1: '',
                line2: '',
                city: '',
                state: '',
                country: '',
                postalCode: _zipController.text,
              ),
            ),
          ),
        ),
      );

      print('Payment confirmed successfully');
      print('Payment Result: $paymentResult');

      // Extract payment details from the result
      final paymentIntent = paymentResult;
      final paymentMethodId = paymentMethod.id;

      // Log all the important IDs and details
      print('=== PAYMENT DETAILS ===');
      print('Payment Intent ID: ${paymentIntent?.id}');
      print('Payment Method ID: $paymentMethodId');
      print('Payment Status: ${paymentIntent?.status}');
      print('Amount: ${paymentIntent?.amount}');
      print('Currency: ${paymentIntent?.currency}');
      print('Created: ${paymentIntent?.created}');

      // Prepare payment data for API call
      final paymentData = {
        'invoiceId': invoiceId,
        'amount': widget.amount,
        'methodId': 1, // Default method ID for Stripe
        'paymentDate': DateTime.now().toIso8601String(),
        'paymentIntentId': paymentIntent?.id ?? '',
        'paymentMethodId': paymentMethodId,
        'status': paymentIntent?.status?.toString() ?? 'succeeded',
        'customerName': _nameController.text,
        'customerZip': _zipController.text,
        'metadata': json.encode({
          'petName': widget.petName,
          'serviceNames': widget.serviceNames,
          'appointmentDate': widget.date,
          'appointmentTime': widget.time,
          'appointmentId': widget.appointmentId,
        }),
        'currency': 'usd',
      };

      print('Payment Data to Send: $paymentData');

      // Call your API to save payment
      final savePaymentResponse = await http.post(
        Uri.parse('${StripeConfig.apiUrl}/Payment'),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      print('Save Payment Response Status: ${savePaymentResponse.statusCode}');
      print('Save Payment Response Body: ${savePaymentResponse.body}');

      if (savePaymentResponse.statusCode == 200 ||
          savePaymentResponse.statusCode == 201) {
        print('Payment saved to database successfully');

        // If we reach here, payment was successful
        if (mounted) {
          print('Payment completed successfully!');
          print('Saving payment details...');

          // Save payment details to local storage
          await _savePaymentDetailsToStorage();

          // Show success popup
          _showPaymentSuccessDialog();
        }
      } else {
        throw Exception(
          'Failed to save payment to database: ${savePaymentResponse.statusCode} - ${savePaymentResponse.body}',
        );
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
