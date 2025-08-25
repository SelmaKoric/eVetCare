import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../utils/authorization.dart';
import '../core/config.dart' as config;
import 'add_pet_page.dart';
import 'edit_pet_page.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('=== SERVER CONFIGURATION ===');
      print('API Server: ${config.baseUrl}');
      print(
        'Loading pets from: ${config.baseUrl}/Pets?OwnerId=${Authorization.userId}',
      );
      print('===========================');

      final pets = await AppointmentService.getPets();
      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _editPet(Map<String, dynamic> petData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPetPage(petData: petData)),
    ).then((success) {
      if (success == true) {
        _loadPets();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet updated successfully!'),
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
        backgroundColor: const Color.fromARGB(255, 90, 183, 226),
        title: const Text("My Pets"),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPets),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _pets.isEmpty
          ? _buildEmptyState()
          : _buildPetsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetPage()),
          ).then((_) {
            _loadPets();
          });
        },
        backgroundColor: const Color.fromARGB(255, 90, 183, 226),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading pets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPets,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 90, 183, 226),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No pets yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPetPage()),
              ).then((_) {
                _loadPets();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 90, 183, 226),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    return RefreshIndicator(
      onRefresh: _loadPets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pets.length,
        itemBuilder: (context, index) {
          final pet = _pets[index];
          return _buildPetCard(pet);
        },
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    print('=== PET DATA DEBUG ===');
    print('Full pet data: $pet');
    print('Available keys: ${pet.keys.toList()}');
    print('Species related fields:');
    print('  speciesName: ${pet['speciesName']}');
    print('  species: ${pet['species']}');
    print('  speciesId: ${pet['speciesId']}');
    print('  SpeciesName: ${pet['SpeciesName']}');
    print('  Species: ${pet['Species']}');
    print('========================');

    final petId = pet['petId'] ?? pet['id'];
    final petName = pet['name'] ?? 'Unknown Pet';
    final breed = pet['breed'] ?? 'Unknown Breed';
    final age = pet['age'] ?? 0;
    final rawWeight = (pet['weight'] is num)
        ? (pet['weight'] as num).toDouble()
        : double.tryParse(pet['weight']?.toString() ?? '0.0') ?? 0.0;

    final weight = rawWeight / 10.0;

    final species =
        pet['speciesName'] ??
        pet['species'] ??
        pet['SpeciesName'] ??
        pet['Species'] ??
        'Unknown Species';
    final gender =
        pet['genderName'] ??
        pet['gender'] ??
        pet['GenderName'] ??
        pet['Gender'] ??
        'Unknown Gender';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 90, 183, 226).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pets,
                size: 30,
                color: Color.fromARGB(255, 90, 183, 226),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$breed • $species',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$gender • ${age} years • ${weight.toStringAsFixed(1)} kg',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 90, 183, 226).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () => _editPet(pet),
                icon: const Icon(Icons.edit_outlined),
                color: const Color.fromARGB(255, 90, 183, 226),
                tooltip: 'Edit pet',
                style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
