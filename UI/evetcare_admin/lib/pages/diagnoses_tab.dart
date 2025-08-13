import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/models/diagnosis.dart';
import 'package:evetcare_admin/pages/medical_history_page.dart';

class DiagnosesTab extends StatelessWidget {
  final Patient patient;
  final List<MedicalRecord> medicalRecords;

  const DiagnosesTab({
    super.key,
    required this.patient,
    required this.medicalRecords,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalHistoryTabList<Diagnosis>(
      patient: patient,
      medicalRecords: medicalRecords,
      extract: (medicalRecord) => medicalRecord.diagnoses ?? [],
      itemBuilder: (diagnosis) => ListTile(
        leading: const Icon(Icons.medical_information_outlined),
        title: Text(diagnosis?.description ?? ''),
      ),
      emptyText: 'No diagnoses found.',
    );
  }
}
