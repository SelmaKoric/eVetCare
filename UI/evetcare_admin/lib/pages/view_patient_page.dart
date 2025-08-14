import 'package:evetcare_admin/core/config.dart';
import 'package:evetcare_admin/models/appointment.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/pages/medical_history_page.dart';
import 'package:evetcare_admin/pages/view_all_appointments_page.dart';
import 'package:evetcare_admin/pages/add_medical_record_modal.dart';
import 'package:evetcare_admin/providers/patient_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ViewPatientPage extends StatefulWidget {
  final Patient patient;

  const ViewPatientPage({super.key, required this.patient});

  @override
  _ViewPatientScreenState createState() => _ViewPatientScreenState();
}

class _ViewPatientScreenState extends State<ViewPatientPage> {
  List<Appointment> _appointments = [];
  bool _isLoadingAppointments = true;
  Map<int, MedicalRecord?> _medicalRecords =
      {}; // appointmentId -> medicalRecord

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final fetchedAppointments = await patientProvider
          .getAppointmentsForPatient(widget.patient.petId!);

      // Create medical records map from appointment data
      final Map<int, MedicalRecord?> medicalRecords = {};

      for (final appointment in fetchedAppointments) {
        if (appointment.medicalRecordId != null) {
          // Create a basic medical record from appointment data
          medicalRecords[appointment.appointmentId] = MedicalRecord(
            medicalRecordId: appointment.medicalRecordId!,
            petId: appointment.petId,
            petName: appointment.petName,
            appointmentId: appointment.appointmentId,
            date: DateTime.parse(appointment.date),
            notes: null,
            analysisProvided: null,
            diagnoses: [],
            treatments: [],
            labResults: [],
            vaccinations: [],
          );
        } else {
          medicalRecords[appointment.appointmentId] = null;
        }
      }

      setState(() {
        _appointments = fetchedAppointments;
        _medicalRecords = medicalRecords;
        _isLoadingAppointments = false;
      });
    } catch (e) {
      setState(() => _isLoadingAppointments = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.name} - Details'),
        backgroundColor: const Color(0xFF5AB7E2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image:
                          (widget.patient.photoUrl != null &&
                              widget.patient.photoUrl!.isNotEmpty)
                          ? NetworkImage('$baseUrl${widget.patient.photoUrl!}')
                          : const AssetImage(
                                  'assets/images/placeholder_pet.png',
                                )
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                const SizedBox(width: 24),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Patient Details",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5AB7E2),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow("Name:", widget.patient.name),
                                _buildDetailRow("Breed:", widget.patient.breed),
                                _buildDetailRow(
                                  "Age:",
                                  widget.patient.age?.toString(),
                                ),
                                _buildDetailRow(
                                  "Gender:",
                                  widget.patient.genderName,
                                ),
                                _buildDetailRow(
                                  "Species:",
                                  widget.patient.species,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MedicalHistoryPage(
                                          patient: widget.patient,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Medical History",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5AB7E2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Owner Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5AB7E2),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  "Owner Name:",
                                  widget.patient.ownerName
                                      ?.replaceAll('\n', ' ')
                                      .trim(),
                                ),
                                _buildDetailRow(
                                  "Phone:",
                                  widget.patient.ownerPhoneNumber,
                                ),
                                _buildDetailRow(
                                  "Email:",
                                  widget.patient.ownerEmail,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              "Appointments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5AB7E2),
              ),
            ),
            const SizedBox(height: 15),
            _isLoadingAppointments
                ? const Center(child: CircularProgressIndicator())
                : _buildAppointmentsTable(),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ViewAllAppointmentsPage(patient: widget.patient),
                    ),
                  );
                },
                child: const Text(
                  "More Appointments >",
                  style: TextStyle(color: Color(0xFF5AB7E2)),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    "Back",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to Edit Patient screen, passing widget.patient
                    print("Edit button pressed for ${widget.patient.name}");
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AB7E2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          IntrinsicWidth(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (value ?? 'N/A').replaceAll('\n', ' ').trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTable() {
    if (_appointments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No appointments found.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Sort appointments by date (newest first) and take the first 3
    final sortedAppointments = List<Appointment>.from(_appointments);
    sortedAppointments.sort(
      (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
    );
    final appointmentsToShow = sortedAppointments.take(3).toList();

    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 0,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(
            label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              "Services",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Actions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: appointmentsToShow.map((appointment) {
          return DataRow(
            cells: [
              DataCell(Text(_formatDate(appointment.date))),
              DataCell(Text(appointment.time)),
              DataCell(
                Text(
                  appointment.serviceNames.isNotEmpty
                      ? appointment.serviceNamesString
                      : "N/A",
                ),
              ),
              DataCell(_buildMedicalRecordButton(appointment)),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildMedicalRecordButton(Appointment appointment) {
    final existingRecord = _medicalRecords[appointment.appointmentId];

    if (existingRecord != null) {
      // Show Edit button for existing records
      return ElevatedButton.icon(
        onPressed: () =>
            _showEditMedicalRecordModal(appointment, existingRecord),
        icon: const Icon(Icons.edit, size: 16),
        label: const Text("Edit", style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5AB7E2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // Show Add Note button for appointments without records
      return ElevatedButton.icon(
        onPressed: () => _showAddMedicalRecordModal(appointment),
        icon: const Icon(Icons.note_add, size: 16),
        label: const Text("Add Note", style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5AB7E2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showAddMedicalRecordModal(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AddMedicalRecordModal(
        patient: widget.patient,
        appointment: appointment,
      ),
    ).then((result) {
      if (result == true) {
        _loadAppointments(); // Refresh to show the new record
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showEditMedicalRecordModal(
    Appointment appointment,
    MedicalRecord record,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddMedicalRecordModal(
        patient: widget.patient,
        appointment: appointment,
        existingRecord: record,
      ),
    ).then((result) {
      if (result == true) {
        _loadAppointments(); // Refresh to show updated record
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
