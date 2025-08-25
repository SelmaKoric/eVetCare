import 'package:flutter/material.dart';
import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/appointment.dart';
import 'package:evetcare_admin/models/medical_record.dart';
import 'package:evetcare_admin/models/lab_test.dart';
import 'package:evetcare_admin/providers/medical_record_provider.dart';
import 'package:intl/intl.dart';

class AddMedicalRecordModal extends StatefulWidget {
  final Patient patient;
  final Appointment appointment;
  final MedicalRecord? existingRecord;

  const AddMedicalRecordModal({
    super.key,
    required this.patient,
    required this.appointment,
    this.existingRecord,
  });

  @override
  State<AddMedicalRecordModal> createState() => _AddMedicalRecordModalState();
}

class _AddMedicalRecordModalState extends State<AddMedicalRecordModal>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _analysisController = TextEditingController();
  final _vaccinationController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _labResultValueController = TextEditingController();

  DateTime? _vaccinationDateGiven;
  DateTime? _vaccinationNextDue;
  LabTest? _selectedLabTest;
  List<LabTest> _labTests = [];
  bool _isLoadingLabTests = false;

  bool _isLoading = false;
  bool _isEditing = false;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _isEditing = widget.existingRecord != null;
    if (_isEditing) {
      _populateFields();
    }
    _loadLabTests();
  }

  void _populateFields() {
    final record = widget.existingRecord!;

    final notes = record.notes ?? '';
    final analysis = record.analysisProvided ?? '';

    final lines = notes.split('\n');
    String vaccination = '';
    String diagnosis = '';
    String treatment = '';
    String additionalNotes = '';

    for (final line in lines) {
      if (line.startsWith('Vaccination:')) {
        vaccination = line.replaceFirst('Vaccination:', '').trim();
      } else if (line.startsWith('Diagnosis:')) {
        diagnosis = line.replaceFirst('Diagnosis:', '').trim();
      } else if (line.startsWith('Treatment:')) {
        treatment = line.replaceFirst('Treatment:', '').trim();
      } else if (line.startsWith('Notes:')) {
        additionalNotes = line.replaceFirst('Notes:', '').trim();
      }
    }

    _vaccinationController.text = vaccination;
    _diagnosisController.text = diagnosis;
    _treatmentController.text = treatment;
    _notesController.text = additionalNotes;
    _analysisController.text = analysis;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _analysisController.dispose();
    _vaccinationController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _labResultValueController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadLabTests() async {
    setState(() {
      _isLoadingLabTests = true;
    });

    try {
      final medicalRecordProvider = MedicalRecordProvider();
      final labTests = await medicalRecordProvider.getLabTests();
      print(
        'Loaded ${labTests.length} lab tests: ${labTests.map((lt) => lt.name).join(', ')}',
      );
      setState(() {
        _labTests = labTests;
        _isLoadingLabTests = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLabTests = false;
      });
      print('Failed to load lab tests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lab tests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    print('=== FORM SUBMISSION STARTED ===');
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    print('✅ Form validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      final medicalRecordProvider = MedicalRecordProvider();

      if (widget.appointment.medicalRecordId == null ||
          widget.appointment.medicalRecordId == 0) {
        throw Exception(
          'Appointment must have a valid medicalRecordId to add medical data',
        );
      }

      final medicalRecordId = widget.appointment.medicalRecordId!;
      print('✅ Using medical record ID from appointment: $medicalRecordId');

      final List<String> calledApis = [];

      if (_treatmentController.text.trim().isNotEmpty) {
        try {
          print('Calling Treatment API...');
          await medicalRecordProvider.createTreatment(
            medicalRecordId: medicalRecordId,
            treatmentDescription: _treatmentController.text.trim(),
          );
          calledApis.add('Treatment');
          print('✅ Treatment API called successfully');
        } catch (e) {
          print('❌ Failed to call Treatment API: $e');
        }
      }

      if (_diagnosisController.text.trim().isNotEmpty) {
        try {
          print('Calling Diagnosis API...');
          await medicalRecordProvider.createDiagnosis(
            medicalRecordId: medicalRecordId,
            description: _diagnosisController.text.trim(),
          );
          calledApis.add('Diagnosis');
          print('✅ Diagnosis API called successfully');
        } catch (e) {
          print('❌ Failed to call Diagnosis API: $e');
        }
      }

      print('=== VACCINATION CHECK ===');
      print('Vaccination text: "${_vaccinationController.text.trim()}"');
      print('Date given: $_vaccinationDateGiven');
      print('Next due: $_vaccinationNextDue');

      if (_vaccinationController.text.trim().isNotEmpty &&
          _vaccinationDateGiven != null &&
          _vaccinationNextDue != null) {
        print('✅ All vaccination fields are filled, calling API...');
        try {
          print('Calling Vaccination API...');
          await medicalRecordProvider.createVaccination(
            medicalRecordId: medicalRecordId,
            name: _vaccinationController.text.trim(),
            dateGiven: _vaccinationDateGiven!,
            nextDue: _vaccinationNextDue!,
          );
          calledApis.add('Vaccination');
          print('✅ Vaccination API called successfully');
        } catch (e) {
          print('❌ Failed to call Vaccination API: $e');
          throw Exception('Vaccination API failed: $e');
        }
      } else {
        print('❌ Vaccination fields not complete, skipping API call');
      }

      if (_selectedLabTest != null &&
          _selectedLabTest!.labTestId != null &&
          _labResultValueController.text.trim().isNotEmpty) {
        try {
          print('Calling Lab Result API...');
          await medicalRecordProvider.createLabResult(
            medicalRecordId: medicalRecordId,
            labTestId: _selectedLabTest!.labTestId!,
            resultValue: _labResultValueController.text.trim(),
            testName: _selectedLabTest!.name,
          );
          calledApis.add('Lab Result');
          print('✅ Lab Result API called successfully');
        } catch (e) {
          print('❌ Failed to call Lab Result API: $e');
        }
      }

      if (mounted) {
        final successMessage = _isEditing
            ? 'Medical record updated successfully!'
            : 'Medical record created successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isEditing ? 'update' : 'add'} medical record: ${e.toString()}',
            ),
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.medical_services,
                    color: const Color(0xFF5AB7E2),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Medical Record' : 'Add Medical Record',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5AB7E2),
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

              // Patient and Appointment Info
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

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController!,
                  labelColor: const Color(0xFF5AB7E2),
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: const Color(0xFF5AB7E2),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.vaccines_outlined),
                      text: 'Vaccination',
                    ),
                    Tab(
                      icon: Icon(Icons.medical_information_outlined),
                      text: 'Diagnosis',
                    ),
                    Tab(icon: Icon(Icons.healing_outlined), text: 'Treatment'),
                    Tab(
                      icon: Icon(Icons.analytics_outlined),
                      text: 'Lab Results',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController!,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vaccination Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5AB7E2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _vaccinationController,
                            decoration: const InputDecoration(
                              labelText: 'Vaccination Name',
                              hintText: 'Enter vaccination name...',
                              prefixIcon: Icon(Icons.vaccines_outlined),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 1,
                          ),

                          const SizedBox(height: 16),

                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    _vaccinationDateGiven ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() {
                                  _vaccinationDateGiven = date;
                                  if (_vaccinationNextDue != null &&
                                      _vaccinationNextDue!.isBefore(date)) {
                                    _vaccinationNextDue = null;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _vaccinationDateGiven != null
                                        ? 'Date Given: ${_vaccinationDateGiven!.day}/${_vaccinationDateGiven!.month}/${_vaccinationDateGiven!.year}'
                                        : 'Select Date Given',
                                    style: TextStyle(
                                      color: _vaccinationDateGiven != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          InkWell(
                            onTap: () async {
                              final minDate =
                                  _vaccinationDateGiven ?? DateTime.now();

                              final date = await showDatePicker(
                                context: context,
                                initialDate: _vaccinationNextDue ?? minDate,
                                firstDate: minDate,
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() {
                                  _vaccinationNextDue = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _vaccinationNextDue != null
                                        ? 'Next Due: ${_vaccinationNextDue!.day}/${_vaccinationNextDue!.month}/${_vaccinationNextDue!.year}'
                                        : 'Select Next Due Date',
                                    style: TextStyle(
                                      color: _vaccinationNextDue != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Diagnosis Tab
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diagnosis Details',
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
                              labelText: 'Diagnosis',
                              hintText: 'Enter diagnosis details...',
                              prefixIcon: Icon(
                                Icons.medical_information_outlined,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),

                    // Treatment Tab
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Treatment Details',
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
                              labelText: 'Treatment',
                              hintText: 'Enter treatment details...',
                              prefixIcon: Icon(Icons.healing_outlined),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),

                    // Lab Results Tab
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lab Results Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5AB7E2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _isLoadingLabTests
                                ? const Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Loading lab tests...'),
                                    ],
                                  )
                                : _labTests.isEmpty
                                ? const Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('No lab tests available'),
                                    ],
                                  )
                                : DropdownButtonFormField<LabTest>(
                                    value: _selectedLabTest,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Lab Test',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    items: [
                                      const DropdownMenuItem<LabTest>(
                                        value: null,
                                        child: Text('Select a lab test...'),
                                      ),
                                      ..._labTests.map(
                                        (labTest) => DropdownMenuItem<LabTest>(
                                          value: labTest,
                                          child: Text(
                                            labTest.name ?? 'Unknown Test',
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (LabTest? value) {
                                      setState(() {
                                        _selectedLabTest = value;
                                      });
                                    },
                                  ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _labResultValueController,
                            decoration: const InputDecoration(
                              labelText: 'Lab Result Value',
                              hintText: 'Enter lab result value...',
                              prefixIcon: Icon(Icons.analytics_outlined),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5AB7E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(_isEditing ? 'Update Record' : 'Add Record'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
