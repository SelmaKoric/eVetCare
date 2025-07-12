import 'package:evetcare_admin/core/config.dart' as config;
import 'package:evetcare_admin/models/genders.dart';
import 'package:evetcare_admin/models/species.dart';
import 'package:evetcare_admin/models/user.dart';
import 'package:evetcare_admin/providers/patient_provider.dart';
import 'package:evetcare_admin/providers/user_provider.dart';
import 'package:evetcare_admin/utils/authorization.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import '../utils/logging.dart';
import 'package:flutter/services.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _ownerFirstName = TextEditingController();
  final _ownerLastName = TextEditingController();
  final _ownerEmail = TextEditingController();
  final _ownerPhoneNumber = TextEditingController();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final TextEditingController _ownerSearchController = TextEditingController();

  List<Species> _speciesOptions = [];
  List<Gender> _genderOptions = [];
  List<User> _ownerOptions = [];
  Species? _selectedSpecies;
  Gender? _selectedGender;
  User? _selectedOwner;

  File? _photo;
  bool _isLoadingLookups = true;

  @override
  void initState() {
    super.initState();
    _loadLookupData();
  }

  Future<void> _loadLookupData() async {
    try {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final fetchedSpecies = await patientProvider.getSpecies();
      final fetchedGenders = await patientProvider.getGenders();
      final fetchedOwners = await userProvider.getAllOwners();

      setState(() {
        _speciesOptions = fetchedSpecies;
        _genderOptions = fetchedGenders;
        _ownerOptions = fetchedOwners;
        _isLoadingLookups = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load options: ${e.toString()}')),
      );
      setState(() {
        _isLoadingLookups = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _photo = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly.'),
        ),
      );
      return;
    }

    if (_selectedSpecies == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Species and Gender.')),
      );
      return;
    }

    try {
      final uri = Uri.parse('${config.baseUrl}/Pets');
      final request = http.MultipartRequest("POST", uri)
        ..fields['name'] = _name.text.trim()
        ..fields['speciesId'] = _selectedSpecies!.speciesId.toString()
        ..fields['breed'] = _breed.text.trim()
        ..fields['genderId'] = _selectedGender!.genderId.toString()
        ..fields['age'] = _age.text.trim()
        ..fields['weight'] = _weight.text.trim();

      if (_selectedOwner != null) {
        request.fields['ownerId'] = _selectedOwner!.userId.toString();
      } else {
        request.fields['ownerFirstName'] = _ownerFirstName.text.trim();
        request.fields['ownerLastName'] = _ownerLastName.text.trim();
        request.fields['ownerEmail'] = _ownerEmail.text.trim();
        request.fields['ownerPhoneNumber'] = _ownerPhoneNumber.text.trim();
      }

      if (_photo != null) {
        final stream = http.ByteStream(_photo!.openRead());
        final length = await _photo!.length();
        final filename = _photo!.path.split('/').last;

        request.files.add(
          http.MultipartFile(
            'photo',
            stream,
            length,
            filename: filename,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      request.headers.addAll({
        'Authorization': 'Bearer ${Authorization.token}',
      });

      ApiLogger.logRequest(
        method: 'POST (Multipart)',
        url: uri.toString(),
        headers: request.headers,
        body: request.fields,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adding patient...')));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      ApiLogger.logResponse(
        statusCode: response.statusCode,
        url: uri.toString(),
        body: responseBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient added successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add patient: ${responseBody.isNotEmpty ? responseBody : 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Patient",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5AB7E2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingLookups
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _photo != null
                                  ? FileImage(_photo!)
                                  : const AssetImage(
                                          'assets/images/placeholder_pet.png',
                                        )
                                        as ImageProvider,
                              child: _photo == null
                                  ? Icon(
                                      Icons.pets,
                                      size: 60,
                                      color: Colors.grey.shade400,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 28,
                                  color: Color(0xFF5AB7E2),
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Owner Information"),

                      Autocomplete<User>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<User>.empty();
                          }

                          return _ownerOptions.where((user) {
                            final fullText =
                                '${user.firstName} ${user.lastName} ${user.email}'
                                    .toLowerCase();
                            return fullText.contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        displayStringForOption: (User option) =>
                            '${option.firstName} ${option.lastName} (${option.email})',
                        fieldViewBuilder:
                            (
                              BuildContext context,
                              TextEditingController fieldTextEditingController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Search Existing Owner (optional)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              );
                            },
                        onSelected: (User selected) {
                          setState(() {
                            _selectedOwner = selected;
                            _ownerFirstName.text = selected.firstName!;
                            _ownerLastName.text = selected.lastName!;
                            _ownerEmail.text = selected.email!;
                            _ownerPhoneNumber.text = selected.phoneNumber ?? '';
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedOwner = null;
                            _ownerSearchController.clear();
                            _ownerFirstName.clear();
                            _ownerLastName.clear();
                            _ownerEmail.clear();
                            _ownerPhoneNumber.clear();
                          });
                        },
                        child: const Text("Clear selected owner"),
                      ),

                      const SizedBox(height: 16),
                      _buildTwoColumnRow(
                        _buildTextField(
                          _ownerFirstName,
                          "First Name",
                          validator: _requiredValidator,
                          enabled: _selectedOwner == null,
                        ),
                        _buildTextField(
                          _ownerLastName,
                          "Last Name",
                          validator: _requiredValidator,
                          enabled: _selectedOwner == null,
                        ),
                      ),
                      _buildTwoColumnRow(
                        _buildTextField(
                          _ownerEmail,
                          "Email",
                          keyboard: TextInputType.emailAddress,
                          validator: _emailValidator,
                          enabled: _selectedOwner == null,
                        ),
                        _buildTextField(
                          _ownerPhoneNumber,
                          "Phone Number",
                          keyboard: TextInputType.phone,
                          validator: _phoneValidator,
                          enabled: _selectedOwner == null,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Pet Information"),
                      _buildTwoColumnRow(
                        _buildTextField(
                          _name,
                          "Pet Name",
                          validator: _requiredValidator,
                        ),
                        _buildDropdown<Species>(
                          label: "Species",
                          value: _selectedSpecies,
                          items: _speciesOptions
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedSpecies = val),
                          validator: (val) =>
                              val == null ? 'Species is required' : null,
                        ),
                      ),
                      _buildTwoColumnRow(
                        _buildTextField(
                          _breed,
                          "Breed",
                          validator: _requiredValidator,
                        ),
                        _buildDropdown<Gender>(
                          label: "Gender",
                          value: _selectedGender,
                          items: _genderOptions
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g.name ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                          validator: (val) =>
                              val == null ? 'Gender is required' : null,
                        ),
                      ),
                      _buildTwoColumnRow(
                        _buildTextField(
                          _age,
                          "Age (years)",
                          keyboard: TextInputType.number,
                          validator: _requiredValidator,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        _buildTextField(
                          _weight,
                          "Weight (kg)",
                          keyboard: TextInputType.number,
                          validator: _requiredValidator,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5AB7E2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Add Patient",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5AB7E2),
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF5AB7E2), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        keyboardType: keyboard,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  @override
  void dispose() {
    _ownerSearchController.dispose();
    _ownerFirstName.dispose();
    _ownerLastName.dispose();
    _ownerEmail.dispose();
    _ownerPhoneNumber.dispose();
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _weight.dispose();
    super.dispose();
  }
}

Widget _buildDropdown<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
  String? Function(T?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5AB7E2), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    ),
  );
}

String? _requiredValidator(String? value) =>
    value == null || value.isEmpty ? 'This field is required' : null;

String? _emailValidator(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? _phoneValidator(String? value) {
  if (value == null || value.isEmpty) return 'Phone number is required';
  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(value)) {
    return 'Enter a valid phone number';
  }
  return null;
}
