import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import 'add_pet_page.dart';
import 'book_appointment_page.dart';
import 'notifications_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 183, 226),
        title: const Text("eVetCare Mobile"),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Authorization.token = null;
              Authorization.userId = null;
              Authorization.user = null;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Pet Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  print("Add Pet button pressed!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPetPage()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Pet"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Book Appointment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  print("Book Appointment button pressed!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookAppointmentPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text("Book Appointment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Notifications Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  print("Notifications button pressed!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications),
                label: const Text("Notifications"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Test button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  print("Test button pressed!");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test button works!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Test Button"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("FAB pressed!");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 90, 183, 226),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
