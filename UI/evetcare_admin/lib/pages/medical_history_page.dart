import 'package:evetcare_admin/pages/diagnoses_tab.dart';
import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/providers/medical_record_provider.dart';
import 'package:evetcare_admin/models/treatment.dart';
import 'package:evetcare_admin/models/lab_result.dart';
import 'package:evetcare_admin/models/vaccination.dart';
import 'package:intl/intl.dart';

class MedicalHistoryPage extends StatefulWidget {
  final Patient patient;

  const MedicalHistoryPage({super.key, required this.patient});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Diagnoses',
    'Treatments',
    'Lab Results',
    'Vaccinations',
  ];

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
          TreatmentsTab(patient: widget.patient),
          LabResultsTab(patient: widget.patient),
          VaccinationsTab(patient: widget.patient),
        ],
      ),
    );
  }
}

class TreatmentsTab extends StatelessWidget {
  final Patient patient;
  const TreatmentsTab({super.key, required this.patient});
  @override
  Widget build(BuildContext context) {
    return _MedicalHistoryTabList<Treatment>(
      patient: patient,
      extract: (record) => record.treatments,
      itemBuilder: (treatment) => ListTile(
        leading: const Icon(Icons.healing_outlined),
        title: Text(treatment?.treatmentDescription ?? ''),
      ),
      emptyText: 'No treatments found.',
    );
  }
}

class LabResultsTab extends StatelessWidget {
  final Patient patient;
  const LabResultsTab({super.key, required this.patient});
  @override
  Widget build(BuildContext context) {
    return _MedicalHistoryTabList<LabResult>(
      patient: patient,
      extract: (record) => record.labResults,
      itemBuilder: (lab) => ListTile(
        leading: const Icon(Icons.science_outlined),
        title: Text('Result: ${lab?.resultValue ?? ''}'),
        subtitle: Text('Test: ${lab?.testName ?? 'Unknown'}'),
      ),
      emptyText: 'No lab results found.',
    );
  }
}

class VaccinationsTab extends StatelessWidget {
  final Patient patient;
  const VaccinationsTab({super.key, required this.patient});
  @override
  Widget build(BuildContext context) {
    return _MedicalHistoryTabList<Vaccination>(
      patient: patient,
      extract: (record) => record.vaccinations,
      itemBuilder: (vax) => ListTile(
        leading: const Icon(Icons.vaccines_outlined),
        title: Text(vax?.name ?? ''),
        subtitle: Text(
          'Given: ${vax?.dateGiven != null ? DateFormat('dd/MM/yyyy').format(vax!.dateGiven) : ''}\nNext Due: ${vax?.nextDue != null ? DateFormat('dd/MM/yyyy').format(vax!.nextDue) : ''}',
        ),
      ),
      emptyText: 'No vaccinations found.',
    );
  }
}

class _MedicalHistoryTabList<E> extends StatelessWidget {
  final Patient patient;
  final List<E> Function(MedicalRecord) extract;
  final Widget Function(E) itemBuilder;
  final String emptyText;
  const _MedicalHistoryTabList({
    required this.patient,
    required this.extract,
    required this.itemBuilder,
    required this.emptyText,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MedicalRecord>>(
      future: MedicalRecordProvider().getMedicalRecordsByPetName(patient.name!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final records = snapshot.data ?? [];
        final items = records.expand(extract).toList();
        if (items.isEmpty) {
          return Center(child: Text(emptyText));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: itemBuilder(items[index]),
              ),
            );
          },
        );
      },
    );
  }
}
