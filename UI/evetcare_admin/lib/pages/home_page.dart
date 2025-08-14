import 'package:evetcare_admin/pages/patient_page.dart';
import 'package:evetcare_admin/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:evetcare_admin/pages/services_page.dart';
import 'package:evetcare_admin/pages/appointments_calendar_page.dart';
import 'package:evetcare_admin/pages/invoice_page.dart';
import 'package:evetcare_admin/pages/reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool isSidebarExpanded = true;

  final List<Widget> tabs = [
    PatientsPage(),
    AppointmentsCalendarPage(),
    ReportsPage(),
    ServicesPage(),
    InvoicePage(),
  ];

  final List<String> tabTitles = [
    "Patients",
    "Appointments Calendar",
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
            onExpandedChanged: (expanded) {
              setState(() {
                isSidebarExpanded = expanded;
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
