import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/stripe_config.dart';
import 'utils/stripe_validator.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_pet_page.dart';
import 'pages/book_appointment_page.dart';
import 'pages/appointment_history_page.dart';
import 'pages/notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with error handling
  try {
    // Validate the publishable key using our validator
    if (!StripeValidator.isValidPublishableKey(StripeConfig.publishableKey)) {
      throw Exception(StripeValidator.getValidationMessage());
    }

    // Initialize Stripe with proper configuration
    Stripe.publishableKey = StripeConfig.publishableKey;

    // Initialize PaymentConfiguration for Android
    await Stripe.instance.applySettings();

    print(
      'Stripe initialized successfully with key: ${StripeConfig.publishableKey.substring(0, 10)}...',
    );
    print('Mode: ${StripeValidator.getModeDescription()}');
    print('Validation: ${StripeValidator.getValidationMessage()}');
  } catch (e) {
    print('Error initializing Stripe: $e');
    print(
      'Please check your Stripe configuration in lib/core/stripe_config.dart',
    );
    // Continue app initialization even if Stripe fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eVetCare Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 90, 183, 226),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/add-pet': (context) => const AddPetPage(),
        '/book-appointment': (context) => const BookAppointmentPage(),
        '/appointment-history': (context) => const AppointmentHistoryPage(),
        '/notifications': (context) => const NotificationsPage(),
        // Payment route should not be used directly - use Navigator.push with parameters instead
        // '/payment': (context) => const PaymentPage(...),
      },
    );
  }
}
