import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_pet_page.dart';
import 'pages/book_appointment_page.dart';
import 'pages/appointment_history_page.dart';
import 'pages/notifications_page.dart';

void main() {
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
      },
    );
  }
}
