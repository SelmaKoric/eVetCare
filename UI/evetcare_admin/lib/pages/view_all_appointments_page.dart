import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
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
      setState(() {
        _appointments = data;
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
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
                    ],
                    rows: _appointments.map((appointment) {
                      return DataRow(
                        cells: [
                          DataCell(Text(_formatDate(appointment.date))),
                          DataCell(Text(appointment.time)),
                          DataCell(
                            Text(
                              appointment.serviceNames.isNotEmpty
                                  ? appointment.serviceNames
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
