import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/appointment.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/providers/medical_record_provider.dart';
import 'package:intl/intl.dart';

class AddMedicalDataModal extends StatefulWidget {
  final Patient patient;
  final Appointment appointment;
  final MedicalRecord medicalRecord;

  const AddMedicalDataModal({
    super.key,
    required this.patient,
    required this.appointment,
    required this.medicalRecord,
  });

  @override
  State<AddMedicalDataModal> createState() => _AddMedicalDataModalState();
}

class _AddMedicalDataModalState extends State<AddMedicalDataModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _treatmentController = TextEditingController();

  final _labTestIdController = TextEditingController();
  final _resultValueController = TextEditingController();

  final _diagnosisController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _treatmentController.dispose();
    _labTestIdController.dispose();
    _resultValueController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _submitTreatment() async {
    if (_treatmentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a treatment description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicalRecordProvider = MedicalRecordProvider();
      await medicalRecordProvider.createTreatment(
        medicalRecordId: widget.medicalRecord.medicalRecordId,
        treatmentDescription: _treatmentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add treatment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitLabResult() async {
    if (_labTestIdController.text.trim().isEmpty ||
        _resultValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both lab test ID and result value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final labTestId = int.tryParse(_labTestIdController.text.trim());
    if (labTestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid lab test ID (number)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicalRecordProvider = MedicalRecordProvider();
      await medicalRecordProvider.createLabResult(
        medicalRecordId: widget.medicalRecord.medicalRecordId,
        labTestId: labTestId,
        resultValue: _resultValueController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab result added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add lab result: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitDiagnosis() async {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a diagnosis description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicalRecordProvider = MedicalRecordProvider();
      await medicalRecordProvider.createDiagnosis(
        medicalRecordId: widget.medicalRecord.medicalRecordId,
        description: _diagnosisController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnosis added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add diagnosis: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                    'Add Medical Data',
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
                  const SizedBox(height: 4),
                  Text(
                    'Medical Record ID: ${widget.medicalRecord.medicalRecordId}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicator: BoxDecoration(
                  color: const Color(0xFF5AB7E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                tabs: const [
                  Tab(text: 'Treatment'),
                  Tab(text: 'Lab Result'),
                  Tab(text: 'Diagnosis'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTreatmentTab(),
                  _buildLabResultTab(),
                  _buildDiagnosisTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTab() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Treatment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AB7E2),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _treatmentController,
            decoration: const InputDecoration(
              labelText: 'Treatment Description',
              hintText: 'Enter treatment details...',
              prefixIcon: Icon(Icons.healing_outlined),
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a treatment description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitTreatment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB7E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add Treatment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultTab() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Lab Result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AB7E2),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _labTestIdController,
            decoration: const InputDecoration(
              labelText: 'Lab Test ID',
              hintText: 'Enter lab test ID (number)',
              prefixIcon: Icon(Icons.science_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a lab test ID';
              }
              if (int.tryParse(value.trim()) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _resultValueController,
            decoration: const InputDecoration(
              labelText: 'Result Value',
              hintText: 'Enter test result...',
              prefixIcon: Icon(Icons.analytics_outlined),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a result value';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitLabResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB7E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add Lab Result'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisTab() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Diagnosis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AB7E2),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _diagnosisController,
            decoration: const InputDecoration(
              labelText: 'Diagnosis Description',
              hintText: 'Enter diagnosis details...',
              prefixIcon: Icon(Icons.medical_information_outlined),
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a diagnosis description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitDiagnosis,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB7E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add Diagnosis'),
            ),
          ),
        ],
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
}
