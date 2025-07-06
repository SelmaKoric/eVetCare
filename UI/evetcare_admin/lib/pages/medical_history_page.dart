import 'package:evetcare_admin/pages/diagnoses_tab.dart';
import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';

class MedicalHistoryPage extends StatefulWidget {
  final Patient patient;

  const MedicalHistoryPage({super.key, required this.patient});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Diagnoses', 'Treatments', 'Lab Results', 'Vaccinations'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.name} - Medical History'),
        backgroundColor: const Color(0xFF5AB7E2),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((label) => Tab(text: label)).toList(),
          isScrollable: true,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
  controller: _tabController,
  children: [
    DiagnosesTab(patient: widget.patient),
    const Center(child: Text("Treatments (Coming soon...)")),
    const Center(child: Text("Lab Results (Coming soon...)")),
    const Center(child: Text("Vaccinations (Coming soon...)")),
  ],
)
    );
  }
}