import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/stripe_config.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_pet_page.dart';
import 'pages/book_appointment_page.dart';
import 'pages/appointment_history_page.dart';
import 'pages/notifications_page.dart';
import 'pages/payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey = StripeConfig.publishableKey;

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
        '/payment': (context) => const PaymentPage(
          appointmentId: 0,
          petName: '',
          serviceNames: '',
          date: '',
          time: '',
          amount: 0.0,
        ),
      },
    );
  }
}
