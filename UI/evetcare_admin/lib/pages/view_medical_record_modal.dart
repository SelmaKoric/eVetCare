import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/appointment.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/pages/add_medical_data_modal.dart';
import 'package:intl/intl.dart';

class ViewMedicalRecordModal extends StatefulWidget {
  final Patient patient;
  final Appointment appointment;
  final MedicalRecord medicalRecord;

  const ViewMedicalRecordModal({
    super.key,
    required this.patient,
    required this.appointment,
    required this.medicalRecord,
  });

  @override
  State<ViewMedicalRecordModal> createState() => _ViewMedicalRecordModalState();
}

class _ViewMedicalRecordModalState extends State<ViewMedicalRecordModal> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Color(0xFF5AB7E2),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Medical Record',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5AB7E2),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${widget.patient.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appointment: ${_formatDate(widget.appointment.date)} at ${widget.appointment.time}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Vaccination',
                      _extractSection(
                        widget.medicalRecord.notes ?? '',
                        'Vaccination:',
                      ),
                    ),
                    _buildSection(
                      'Diagnosis',
                      _extractSection(
                        widget.medicalRecord.notes ?? '',
                        'Diagnosis:',
                      ),
                    ),
                    _buildSection(
                      'Treatment',
                      _extractSection(
                        widget.medicalRecord.notes ?? '',
                        'Treatment:',
                      ),
                    ),
                    _buildSection(
                      'Analysis Provided',
                      widget.medicalRecord.analysisProvided ??
                          'No analysis provided',
                    ),
                    _buildSection(
                      'Additional Notes',
                      _extractSection(
                        widget.medicalRecord.notes ?? '',
                        'Notes:',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddMedicalDataModal(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Data"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AB7E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AB7E2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(content, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _extractSection(String notes, String sectionPrefix) {
    final lines = notes.split('\n');
    for (final line in lines) {
      if (line.startsWith(sectionPrefix)) {
        return line.replaceFirst(sectionPrefix, '').trim();
      }
    }
    return '';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void _showAddMedicalDataModal() {
    showDialog(
      context: context,
      builder: (context) => AddMedicalDataModal(
        patient: widget.patient,
        appointment: widget.appointment,
        medicalRecord: widget.medicalRecord,
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
