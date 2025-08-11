import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import '../services/medical_record_service.dart';
import '../utils/authorization.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MedicalRecord> _medicalRecords = [];
  List<Map<String, dynamic>> _pets = [];
  int? _selectedPetId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('MedicalRecordsPage: initState called');
    _tabController = TabController(length: 5, vsync: this);
    print('MedicalRecordsPage: Starting to load pets...');
    _loadPets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    print('MedicalRecordsPage: _loadPets called');
    print('MedicalRecordsPage: Current _isLoading state: $_isLoading');
    print('MedicalRecordsPage: Current _pets length: ${_pets.length}');

    try {
      print('MedicalRecordsPage: Calling MedicalRecordService.getPets()...');
      final pets = await MedicalRecordService.getPets();
      print('MedicalRecordsPage: getPets() returned ${pets.length} pets');
      print('MedicalRecordsPage: Pets data: $pets');

      print('MedicalRecordsPage: About to call setState...');
      setState(() {
        _pets = pets;
        print('MedicalRecordsPage: _pets set to ${_pets.length} pets');
        if (_pets.isNotEmpty && _selectedPetId == null) {
          _selectedPetId = _pets.first['petId'];
          print('MedicalRecordsPage: Auto-selected pet ID: $_selectedPetId');
        }
        print('MedicalRecordsPage: _selectedPetId is now: $_selectedPetId');
      });
      print('MedicalRecordsPage: setState completed');

      // Load medical records after setState to avoid nested setState calls
      if (_pets.isNotEmpty && _selectedPetId != null) {
        print(
          'MedicalRecordsPage: Pets found and selected, triggering medical records load',
        );
        _loadMedicalRecords();
      } else {
        // If no pets or no selected pet, stop loading
        print('MedicalRecordsPage: No pets found or no pet selected');
        print('MedicalRecordsPage: _pets.isEmpty: ${_pets.isEmpty}');
        print('MedicalRecordsPage: _selectedPetId: $_selectedPetId');
        print('MedicalRecordsPage: Setting _isLoading to false...');
        setState(() {
          _isLoading = false;
        });
        print('MedicalRecordsPage: _isLoading set to false');
      }
    } catch (e) {
      print('MedicalRecordsPage: Error loading pets: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('MedicalRecordsPage: Error state set, _isLoading set to false');
    }
  }

  Future<void> _loadMedicalRecords() async {
    if (_selectedPetId == null) {
      print('No pet selected, cannot load medical records');
      return;
    }

    // Prevent multiple simultaneous calls
    if (_isLoading) {
      print('Medical records already loading, skipping...');
      return;
    }

    print('Loading medical records for pet ID: $_selectedPetId');
    print('Authorization token: ${Authorization.token}');
    print('Authorization userId: ${Authorization.userId}');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Calling MedicalRecordService.getMedicalRecords...');

      // Add timeout to prevent infinite loading
      final records =
          await MedicalRecordService.getMedicalRecords(_selectedPetId!).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('Medical records request timed out after 30 seconds');
              throw Exception('Request timed out. Please try again.');
            },
          );

      print('Loaded ${records.length} medical records');

      if (mounted) {
        setState(() {
          _medicalRecords = records;
          _isLoading = false;
        });
        print(
          'Medical records loaded successfully, loading state set to false',
        );
      } else {
        print('Widget not mounted, skipping setState');
      }
    } catch (e) {
      print('Error loading medical records: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        print('Error state set, loading state set to false');
      } else {
        print('Widget not mounted during error, skipping setState');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('MedicalRecordsPage: build() called');
    print('MedicalRecordsPage: _isLoading: $_isLoading');
    print('MedicalRecordsPage: _pets.length: ${_pets.length}');
    print('MedicalRecordsPage: _error: $_error');
    print(
      'MedicalRecordsPage: _medicalRecords.length: ${_medicalRecords.length}',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 183, 226),
        title: const Text(
          "Medical Records",
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Diagnoses'),
            Tab(text: 'Treatments'),
            Tab(text: 'Lab Results'),
            Tab(text: 'Vaccinations'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Pet Selection Dropdown
          if (_pets.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Pet:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedPetId,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                        items: _pets.map((pet) {
                          return DropdownMenuItem<int>(
                            value: pet['petId'],
                            child: Text(
                              pet['name'] ?? 'Unknown Pet',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPetId = value;
                          });
                          _loadMedicalRecords();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Medical Records Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 90, 183, 226),
                      ),
                    ),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading medical records',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadMedicalRecords,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _pets.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No pets found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add a pet to view medical records',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _medicalRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No medical records found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildDiagnosesTab(),
                      _buildTreatmentsTab(),
                      _buildLabResultsTab(),
                      _buildVaccinationsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medicalRecords.length,
      itemBuilder: (context, index) {
        final record = _medicalRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      color: const Color.fromARGB(255, 90, 183, 226),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.petName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: record.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Date',
                  MedicalRecordService.formatDate(record.date),
                ),
                _buildInfoRow(
                  'Appointment ID',
                  record.appointmentId.toString(),
                ),
                if (record.notes.isNotEmpty)
                  _buildInfoRow('Notes', record.notes),
                if (record.analysisProvided.isNotEmpty)
                  _buildInfoRow('Analysis', record.analysisProvided),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildStatChip('Diagnoses', record.diagnoses.length),
                    _buildStatChip('Treatments', record.treatments.length),
                    _buildStatChip('Lab Results', record.labResults.length),
                    _buildStatChip('Vaccinations', record.vaccinations.length),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosesTab() {
    final allDiagnoses = MedicalRecordService.getAllDiagnoses(_medicalRecords);

    if (allDiagnoses.isEmpty) {
      return const Center(child: Text('No diagnoses found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allDiagnoses.length,
      itemBuilder: (context, index) {
        final diagnosis = allDiagnoses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.medical_services, color: Colors.red[600]),
            title: Text(diagnosis.description),
            subtitle: Text('Diagnosis ID: ${diagnosis.diagnosisId}'),
          ),
        );
      },
    );
  }

  Widget _buildTreatmentsTab() {
    final allTreatments = MedicalRecordService.getAllTreatments(
      _medicalRecords,
    );

    if (allTreatments.isEmpty) {
      return const Center(child: Text('No treatments found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allTreatments.length,
      itemBuilder: (context, index) {
        final treatment = allTreatments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.healing, color: Colors.blue[600]),
            title: Text(treatment.treatmentDescription),
            subtitle: Text('Treatment ID: ${treatment.treatmentId}'),
          ),
        );
      },
    );
  }

  Widget _buildLabResultsTab() {
    final allLabResults = MedicalRecordService.getAllLabResults(
      _medicalRecords,
    );

    if (allLabResults.isEmpty) {
      return const Center(child: Text('No lab results found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allLabResults.length,
      itemBuilder: (context, index) {
        final labResult = allLabResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.science, color: Colors.purple[600]),
            title: Text('Result: ${labResult.resultValue}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (labResult.testName != null)
                  Text('Test: ${labResult.testName}'),
                if (labResult.unit != null) Text('Unit: ${labResult.unit}'),
                if (labResult.referenceRange != null)
                  Text('Reference: ${labResult.referenceRange}'),
                Text('Lab Result ID: ${labResult.labResultId}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    final allVaccinations = MedicalRecordService.getAllVaccinations(
      _medicalRecords,
    );

    if (allVaccinations.isEmpty) {
      return const Center(child: Text('No vaccinations found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allVaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = allVaccinations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.vaccines, color: Colors.green[600]),
            title: Text(vaccination.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Given: ${MedicalRecordService.formatDate(vaccination.dateGiven)}',
                ),
                Text(
                  'Next Due: ${MedicalRecordService.formatDate(vaccination.nextDue)}',
                ),
                Text('Vaccination ID: ${vaccination.vaccinationId}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 90, 183, 226).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 90, 183, 226),
          width: 1,
        ),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: const Color.fromARGB(255, 90, 183, 226),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
