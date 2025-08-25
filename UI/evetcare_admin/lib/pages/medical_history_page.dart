import 'package:evetcare_admin/pages/diagnoses_tab.dart';
import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/providers/medical_record_provider.dart';
import 'package:evetcare_admin/models/treatment.dart';
import 'package:evetcare_admin/models/lab_result.dart';
import 'package:evetcare_admin/models/lab_test.dart';
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
  List<MedicalRecord> _medicalRecords = [];
  List<LabTest> _labTests = [];
  bool _isLoading = true;

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
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final medicalRecordProvider = MedicalRecordProvider();

      final results = await Future.wait([
        medicalRecordProvider.getMedicalRecordsByPetId(widget.patient.petId!),
        medicalRecordProvider.getLabTests(),
      ]);

      setState(() {
        _medicalRecords = results[0] as List<MedicalRecord>;
        _labTests = results[1] as List<LabTest>;
        print('Loaded ${_medicalRecords.length} medical records');
        print(
          'Loaded ${_labTests.length} lab tests: ${_labTests.map((lt) => '${lt.labTestId}: ${lt.name}').join(', ')}',
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load medical history: ${e.toString()}'),
          ),
        );
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicalRecords.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No medical records found for this patient.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                DiagnosesTab(
                  patient: widget.patient,
                  medicalRecords: _medicalRecords,
                ),
                TreatmentsTab(
                  patient: widget.patient,
                  medicalRecords: _medicalRecords,
                ),
                LabResultsTab(
                  patient: widget.patient,
                  medicalRecords: _medicalRecords,
                  labTests: _labTests,
                ),
                VaccinationsTab(
                  patient: widget.patient,
                  medicalRecords: _medicalRecords,
                ),
              ],
            ),
    );
  }
}

class TreatmentsTab extends StatelessWidget {
  final Patient patient;
  final List<MedicalRecord> medicalRecords;

  const TreatmentsTab({
    super.key,
    required this.patient,
    required this.medicalRecords,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalHistoryTabList<Treatment>(
      patient: patient,
      medicalRecords: medicalRecords,
      extract: (medicalRecord) => medicalRecord.treatments ?? [],
      itemBuilder: (treatment) => ListTile(
        leading: const Icon(Icons.healing_outlined),
        title: Text(treatment?.treatmentDescription ?? ''),
      ),
      emptyText: 'No treatments found.',
    );
  }
}

class LabResultsTab extends StatefulWidget {
  final Patient patient;
  final List<MedicalRecord> medicalRecords;
  final List<LabTest> labTests;

  const LabResultsTab({
    super.key,
    required this.patient,
    required this.medicalRecords,
    required this.labTests,
  });

  @override
  State<LabResultsTab> createState() => _LabResultsTabState();
}

class _LabResultsTabState extends State<LabResultsTab> {
  String _getTestName(int? labTestId) {
    if (labTestId == null) return 'Unknown';

    print('Looking for lab test ID: $labTestId');
    print(
      'Available lab tests: ${widget.labTests.map((lt) => '${lt.labTestId}: ${lt.name}').join(', ')}',
    );

    final labTest = widget.labTests.firstWhere(
      (test) => test.labTestId == labTestId,
      orElse: () {
        print('Lab test ID $labTestId not found in available tests');
        return LabTest(labTestId: labTestId, name: 'Unknown Test');
      },
    );

    print('Found lab test: ${labTest.labTestId}: ${labTest.name}');
    return labTest.name ?? 'Test ID: $labTestId';
  }

  @override
  Widget build(BuildContext context) {
    return MedicalHistoryTabList<LabResult>(
      patient: widget.patient,
      medicalRecords: widget.medicalRecords,
      extract: (medicalRecord) => medicalRecord.labResults ?? [],
      itemBuilder: (lab) => ListTile(
        leading: const Icon(Icons.science_outlined),
        title: Text('Result: ${lab?.resultValue ?? ''}'),
        subtitle: Text('Test: ${_getTestName(lab?.labTestId)}'),
      ),
      emptyText: 'No lab results found.',
    );
  }
}

class VaccinationsTab extends StatelessWidget {
  final Patient patient;
  final List<MedicalRecord> medicalRecords;

  const VaccinationsTab({
    super.key,
    required this.patient,
    required this.medicalRecords,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalHistoryTabList<Vaccination>(
      patient: patient,
      medicalRecords: medicalRecords,
      extract: (medicalRecord) => medicalRecord.vaccinations ?? [],
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

class MedicalHistoryTabList<E> extends StatelessWidget {
  final Patient patient;
  final List<MedicalRecord> medicalRecords;
  final List<E> Function(MedicalRecord) extract;
  final Widget Function(E) itemBuilder;
  final String emptyText;

  const MedicalHistoryTabList({
    super.key,
    required this.patient,
    required this.medicalRecords,
    required this.extract,
    required this.itemBuilder,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = <E>[];

    for (final medicalRecord in medicalRecords) {
      final items = extract(medicalRecord);
      allItems.addAll(items);
    }

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: itemBuilder(allItems[index]),
          ),
        );
      },
    );
  }
}
