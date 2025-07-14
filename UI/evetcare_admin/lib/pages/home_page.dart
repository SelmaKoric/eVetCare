import 'package:evetcare_admin/pages/patient_page.dart';
import 'package:evetcare_admin/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:evetcare_admin/pages/services_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> tabs = [
    PatientsPage(),
    Center(child: Text("Appointments")),
    Center(child: Text("Reports")),
    ServicesPage(),
    Center(child: Text("Invoices")),
  ];

  final List<String> tabTitles = [
    "Patients",
    "Appointments",
    "Reports",
    "Services",
    "Invoices",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onTabSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: tabTitles,
          ),
          Expanded(child: tabs[selectedIndex]),
        ],
      ),
    );
  }
}
