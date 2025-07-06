import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/providers/medical_record_provider.dart';

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
    _medicalRecordsFuture = MedicalRecordProvider().getMedicalRecordsByPetId(widget.patient.petId!);
  }

  @override
  Widget build(BuildContext context) {
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
        if (records.isEmpty) {
          return const Center(child: Text("No diagnoses found."));
        }

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${record.date.toLocal().toString().split('T').first}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...record.diagnoses.map((d) => ListTile(
                          leading: const Icon(Icons.medical_services_outlined),
                          title: Text(d.description),
                        )),
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