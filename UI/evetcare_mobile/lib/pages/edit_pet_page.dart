import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/api_service.dart';
import '../core/config.dart' as config;
import '../models/gender.dart';
import '../models/species.dart';
import '../models/pet.dart';
import '../utils/authorization.dart';

class EditPetPage extends StatefulWidget {
  final Map<String, dynamic> petData;

  const EditPetPage({super.key, required this.petData});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();

  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  List<Gender> _genders = [];
  Gender? _selectedGender;
  bool _loadingGenders = true;

  List<Species> _species = [];
  Species? _selectedSpecies;
  bool _loadingSpecies = true;

  File? _selectedImageFile;
  String? _selectedImageName;
  String? _existingPhotoUrl;

  bool _isSubmitting = false;

  int? _tempGenderId;
  int? _tempSpeciesId;

  @override
  void initState() {
    super.initState();
    _initializePetData();
    _loadGenders();
    _loadSpecies();
  }

  void _initializePetData() {
    final petData = widget.petData;

    _petNameController.text = petData['name'] ?? '';
    _breedController.text = petData['breed'] ?? '';
    _ageController.text = (petData['age'] ?? 0).toString();
    final rawWeight = (petData['weight'] ?? 0.0);
    final displayWeight = (rawWeight is num) ? (rawWeight as num) / 10.0 : 0.0;
    _weightController.text = displayWeight.toString();
    _existingPhotoUrl = petData['photoUrl'] ?? petData['photo'];

    final petGenderId = petData['genderId'];
    final petSpeciesId = petData['speciesId'];

    _tempGenderId = petGenderId;
    _tempSpeciesId = petSpeciesId;
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadGenders() async {
    try {
      final genders = await ApiService.getGenders();
      setState(() {
        _genders = genders;
        _loadingGenders = false;
      });

      final petGenderId = widget.petData['genderId'];
      if (petGenderId != null) {
        _selectedGender = genders.firstWhere(
          (gender) => gender.genderId == petGenderId,
          orElse: () => genders.first,
        );
      }
    } catch (e) {
      setState(() {
        _loadingGenders = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load genders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSpecies() async {
    try {
      final species = await ApiService.getSpecies();
      setState(() {
        _species = species;
        _loadingSpecies = false;
      });

      final petSpeciesId = widget.petData['speciesId'];
      if (petSpeciesId != null) {
        _selectedSpecies = species.firstWhere(
          (species) => species.speciesId == petSpeciesId,
          orElse: () => species.first,
        );
      }
    } catch (e) {
      setState(() {
        _loadingSpecies = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load species: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 183, 226),
        title: const Text("Edit Pet"),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Pet Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 90, 183, 226),
                ),
              ),
              const SizedBox(height: 16),

              _buildReadOnlyInfo(),
              const SizedBox(height: 16),

              const Text(
                "Editable Fields",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 90, 183, 226),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _ageController,
                label: "Age",
                hint: "e.g., 3 (in years)",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Age is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final age = int.parse(value);
                  if (age < 0) {
                    return 'Age cannot be negative';
                  }
                  if (age > 30) {
                    return 'Age cannot be more than 30 years';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _weightController,
                label: "Weight",
                hint: "e.g., 25.5 (in kg)",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Weight is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final weight = double.parse(value);
                  if (weight <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  if (weight > 200) {
                    return 'Weight cannot be more than 200 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildPhotoUpload(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Update Pet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfo() {
    final petData = widget.petData;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Information (Read-only)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Name", petData['name'] ?? 'Unknown'),
          _buildInfoRow(
            "Species",
            petData['speciesName'] ??
                petData['species'] ??
                petData['SpeciesName'] ??
                petData['Species'] ??
                'Unknown',
          ),
          _buildInfoRow("Breed", petData['breed'] ?? 'Unknown'),
          _buildInfoRow(
            "Gender",
            petData['genderName'] ??
                petData['gender'] ??
                petData['GenderName'] ??
                petData['Gender'] ??
                'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSpeciesDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Species",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Species>(
              value: _selectedSpecies,
              hint: _loadingSpecies
                  ? const Text("Loading species...")
                  : const Text("Select species"),
              isExpanded: true,
              items: _species.map((Species species) {
                return DropdownMenuItem<Species>(
                  value: species,
                  child: Text(species.name),
                );
              }).toList(),
              onChanged: _loadingSpecies
                  ? null
                  : (Species? newValue) {
                      setState(() {
                        _selectedSpecies = newValue;
                      });
                    },
            ),
          ),
        ),
        if (_selectedSpecies == null)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 16),
            child: Text(
              'Please select a species',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Gender>(
              value: _selectedGender,
              hint: _loadingGenders
                  ? const Text("Loading genders...")
                  : const Text("Select gender"),
              isExpanded: true,
              items: _genders.map((Gender gender) {
                return DropdownMenuItem<Gender>(
                  value: gender,
                  child: Text(gender.name),
                );
              }).toList(),
              onChanged: _loadingGenders
                  ? null
                  : (Gender? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
            ),
          ),
        ),
        if (_selectedGender == null)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 16),
            child: Text(
              'Please select a gender',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Photo",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (_selectedImageFile != null) ...[
                // Show selected image preview
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImageName ?? "Selected image",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ] else if (_existingPhotoUrl != null &&
                  _existingPhotoUrl!.isNotEmpty) ...[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      config.buildImageUrl(_existingPhotoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image loading error: $error');
                        print(
                          'Photo URL: ${config.buildImageUrl(_existingPhotoUrl!)}',
                        );
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.pets,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 90, 183, 226),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Current photo",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedImageName ??
                          _existingPhotoUrl ??
                          "No file chosen",
                      style: TextStyle(
                        color:
                            (_selectedImageFile != null ||
                                _existingPhotoUrl != null)
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 90, 183, 226),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Choose File"),
                  ),
                  if (_selectedImageFile != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _removePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Remove"),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        setState(() {
          _selectedImageFile = file;
          _selectedImageName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageName = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (Authorization.user == null || Authorization.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User information not available. Please log in again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final pet = Pet(
          ownerId: Authorization.userId!,
          ownerFirstName: Authorization.user!.firstName,
          ownerLastName: Authorization.user!.lastName,
          ownerEmail: Authorization.user!.email,
          ownerPhoneNumber: Authorization.user!.phoneNumber ?? '',
          name: widget.petData['name'] ?? '',
          speciesId: _tempSpeciesId ?? 1,
          breed: widget.petData['breed'] ?? '',
          genderId: _tempGenderId ?? 1,
          age: int.parse(_ageController.text),
          weight: double.parse(_weightController.text) * 10.0,
          photo: _selectedImageFile != null ? _selectedImageName : '',
        );

        final petId = widget.petData['petId'] ?? widget.petData['id'];

        final success = await ApiService.updatePet(
          petId,
          pet,
          imageFile: _selectedImageFile,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pet updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update pet: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}
