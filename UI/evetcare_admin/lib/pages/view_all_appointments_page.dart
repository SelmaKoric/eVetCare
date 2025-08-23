import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../models/medical_record.dart';
import '../providers/patient_provider.dart';

import '../pages/add_medical_record_modal.dart';

import 'package:intl/intl.dart';

class ViewAllAppointmentsPage extends StatefulWidget {
  final Patient patient;

  const ViewAllAppointmentsPage({super.key, required this.patient});

  @override
  State<ViewAllAppointmentsPage> createState() =>
      _ViewAllAppointmentsScreenState();
}

class _ViewAllAppointmentsScreenState extends State<ViewAllAppointmentsPage> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  Map<int, MedicalRecord?> _medicalRecords = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final provider = Provider.of<PatientProvider>(context, listen: false);
      final data = await provider.getAppointmentsForPatient(
        widget.patient.petId!,
      );

      final Map<int, MedicalRecord?> medicalRecords = {};

      for (final appointment in data) {
        if (appointment.medicalRecordId != null) {
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
        _appointments = data;
        _medicalRecords = medicalRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load appointments: ${e.toString()}")),
      );
    }
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
        _loadAppointments();
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
        _loadAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.patient.name}'s Appointments"),
        backgroundColor: const Color(0xFF5AB7E2),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? const Center(child: Text("No appointments found."))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  headingRowHeight: 56,
                  dataRowMinHeight: 48,
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Time",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Services",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Status",
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
                  rows: _appointments.map((appointment) {
                    return DataRow(
                      cells: [
                        DataCell(Text(_formatDate(appointment.date))),
                        DataCell(Text(appointment.time)),
                        DataCell(
                          Text(
                            appointment.serviceNames.isNotEmpty
                                ? appointment.serviceNamesString
                                : "N/A",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Text(appointment.status ?? "N/A"),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                onSelected: (action) async {
                                  try {
                                    await Provider.of<PatientProvider>(
                                      context,
                                      listen: false,
                                    ).updateAppointmentStatus(
                                      appointment.appointmentId,
                                      action,
                                    );
                                    await _loadAppointments();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to update: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'approve',
                                    child: Text("Approve"),
                                  ),
                                  const PopupMenuItem(
                                    value: 'reject',
                                    child: Text("Reject"),
                                  ),
                                  const PopupMenuItem(
                                    value: 'complete',
                                    child: Text("Complete"),
                                  ),
                                  const PopupMenuItem(
                                    value: 'cancel',
                                    child: Text("Cancel"),
                                  ),
                                ],
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(_buildMedicalRecordButton(appointment)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
