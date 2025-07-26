import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/providers/medical_record_provider.dart';
import 'package:intl/intl.dart';

class DiagnosesTab extends StatefulWidget {
  final Patient patient;

  const DiagnosesTab({super.key, required this.patient});

  @override
  State<DiagnosesTab> createState() => _DiagnosesTabState();
}

class _DiagnosesTabState extends State<DiagnosesTab> {
  late Future<List<MedicalRecord>> _medicalRecordsFuture;

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  void _fetchMedicalRecords() {
    setState(() {
      _medicalRecordsFuture = MedicalRecordProvider()
          .getMedicalRecordsByPetName(widget.patient.name!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildDiagnosesList();
  }

  Widget _buildDiagnosesList() {
    return FutureBuilder<List<MedicalRecord>>(
      future: _medicalRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final records = snapshot.data!;

        // Debug logging
        print('=== DIAGNOSES DEBUG ===');
        print('Patient ID: ${widget.patient.petId}');
        print('Patient Name: ${widget.patient.name}');
        print('Total records: ${records.length}');
        for (int i = 0; i < records.length; i++) {
          final record = records[i];
          print('Record $i:');
          print('  - MedicalRecordId: ${record.medicalRecordId}');
          print('  - PetId: ${record.petId}');
          print('  - PetName: ${record.petName}');
          print('  - Date: ${record.date}');
          print('  - Diagnoses count: ${record.diagnoses.length}');
          for (int j = 0; j < record.diagnoses.length; j++) {
            final diagnosis = record.diagnoses[j];
            print('    Diagnosis $j: ${diagnosis.description}');
          }
        }

        if (records.isEmpty) {
          return const Center(
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
                  "No diagnoses found.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5AB7E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(record.date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.medical_services_outlined,
                          color: Color(0xFF5AB7E2),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...record.diagnoses.map(
                      (diagnosis) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.medical_information_outlined,
                              color: Color(0xFF5AB7E2),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                diagnosis.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
