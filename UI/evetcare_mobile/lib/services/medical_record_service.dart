import '../models/medical_record.dart';
import '../providers/api_provider.dart';

class MedicalRecordService {
  static Future<List<Map<String, dynamic>>> getPets() async {
    return await ApiProvider.getPets();
  }

  static Future<List<MedicalRecord>> getMedicalRecords(int petId) async {
    print('MedicalRecordService: Getting medical records for pet ID: $petId');

    try {
      final recordsData = await ApiProvider.getMedicalRecords(petId);
      print(
        'MedicalRecordService: Received ${recordsData.length} records from API',
      );

      List<MedicalRecord> allRecords = [];
      for (var record in recordsData) {
        try {
          allRecords.add(MedicalRecord.fromJson(record));
        } catch (e) {
          print('MedicalRecordService: Error parsing record: $e');
          print('MedicalRecordService: Record data: $record');
        }
      }

      print(
        'MedicalRecordService: Successfully parsed ${allRecords.length} records',
      );
      return allRecords;
    } catch (e) {
      print('MedicalRecordService: Error getting medical records: $e');
      rethrow;
    }
  }

  // Get all diagnoses from all medical records
  static List<Diagnosis> getAllDiagnoses(List<MedicalRecord> records) {
    final allDiagnoses = <Diagnosis>[];
    for (var record in records) {
      allDiagnoses.addAll(record.diagnoses);
    }
    return allDiagnoses;
  }

  // Get all treatments from all medical records
  static List<Treatment> getAllTreatments(List<MedicalRecord> records) {
    final allTreatments = <Treatment>[];
    for (var record in records) {
      allTreatments.addAll(record.treatments);
    }
    return allTreatments;
  }

  // Get all lab results from all medical records
  static List<LabResult> getAllLabResults(List<MedicalRecord> records) {
    final allLabResults = <LabResult>[];
    for (var record in records) {
      allLabResults.addAll(record.labResults);
    }
    return allLabResults;
  }

  // Get all vaccinations from all medical records
  static List<Vaccination> getAllVaccinations(List<MedicalRecord> records) {
    final allVaccinations = <Vaccination>[];
    for (var record in records) {
      allVaccinations.addAll(record.vaccinations);
    }
    return allVaccinations;
  }

  // Format date string to DD/MM/YYYY format
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Get statistics for medical records
  static Map<String, int> getStatistics(List<MedicalRecord> records) {
    int totalDiagnoses = 0;
    int totalTreatments = 0;
    int totalLabResults = 0;
    int totalVaccinations = 0;

    for (var record in records) {
      totalDiagnoses += record.diagnoses.length;
      totalTreatments += record.treatments.length;
      totalLabResults += record.labResults.length;
      totalVaccinations += record.vaccinations.length;
    }

    return {
      'diagnoses': totalDiagnoses,
      'treatments': totalTreatments,
      'labResults': totalLabResults,
      'vaccinations': totalVaccinations,
    };
  }

  // Filter medical records by date range
  static List<MedicalRecord> filterByDateRange(
    List<MedicalRecord> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      try {
        final recordDate = DateTime.parse(record.date);
        return recordDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            recordDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Sort medical records by date (newest first)
  static List<MedicalRecord> sortByDate(List<MedicalRecord> records) {
    final sortedRecords = List<MedicalRecord>.from(records);
    sortedRecords.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA); // Newest first
      } catch (e) {
        return 0;
      }
    });
    return sortedRecords;
  }

  // Get active medical records only
  static List<MedicalRecord> getActiveRecords(List<MedicalRecord> records) {
    return records.where((record) => record.isActive).toList();
  }

  // Search medical records by text
  static List<MedicalRecord> searchRecords(
    List<MedicalRecord> records,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return records;

    final lowerSearchTerm = searchTerm.toLowerCase();

    return records.where((record) {
      return record.petName.toLowerCase().contains(lowerSearchTerm) ||
          record.notes.toLowerCase().contains(lowerSearchTerm) ||
          record.analysisProvided.toLowerCase().contains(lowerSearchTerm) ||
          record.diagnoses.any(
            (d) => d.description.toLowerCase().contains(lowerSearchTerm),
          ) ||
          record.treatments.any(
            (t) =>
                t.treatmentDescription.toLowerCase().contains(lowerSearchTerm),
          );
    }).toList();
  }
}
