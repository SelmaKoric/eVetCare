class MedicalRecord {
  final int medicalRecordId;
  final int petId;
  final String petName;
  final int appointmentId;
  final String date;
  final String notes;
  final String analysisProvided;
  final List<Diagnosis> diagnoses;
  final List<Treatment> treatments;
  final List<LabResult> labResults;
  final List<Vaccination> vaccinations;
  final bool isActive;

  MedicalRecord({
    required this.medicalRecordId,
    required this.petId,
    required this.petName,
    required this.appointmentId,
    required this.date,
    required this.notes,
    required this.analysisProvided,
    required this.diagnoses,
    required this.treatments,
    required this.labResults,
    required this.vaccinations,
    required this.isActive,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      medicalRecordId: json['medicalRecordId'] ?? 0,
      petId: json['petId'] ?? 0,
      petName: json['petName'] ?? '',
      appointmentId: json['appointmentId'] ?? 0,
      date: json['date'] ?? '',
      notes: json['notes'] ?? '',
      analysisProvided: json['analysisProvided'] ?? '',
      diagnoses:
          (json['diagnoses'] as List<dynamic>?)
              ?.map((d) => Diagnosis.fromJson(d))
              .toList() ??
          [],
      treatments:
          (json['treatments'] as List<dynamic>?)
              ?.map((t) => Treatment.fromJson(t))
              .toList() ??
          [],
      labResults:
          (json['labResults'] as List<dynamic>?)
              ?.map((l) => LabResult.fromJson(l))
              .toList() ??
          [],
      vaccinations:
          (json['vaccinations'] as List<dynamic>?)
              ?.map((v) => Vaccination.fromJson(v))
              .toList() ??
          [],
      isActive: json['isActive'] ?? false,
    );
  }
}

class Diagnosis {
  final int diagnosisId;
  final String description;

  Diagnosis({required this.diagnosisId, required this.description});

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      diagnosisId: json['diagnosisId'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class Treatment {
  final int treatmentId;
  final String treatmentDescription;

  Treatment({required this.treatmentId, required this.treatmentDescription});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      treatmentId: json['treatmentId'] ?? 0,
      treatmentDescription: json['treatmentDescription'] ?? '',
    );
  }
}

class LabResult {
  final int labResultId;
  final int labTestId;
  final String? testName;
  final String resultValue;
  final String? unit;
  final String? referenceRange;

  LabResult({
    required this.labResultId,
    required this.labTestId,
    this.testName,
    required this.resultValue,
    this.unit,
    this.referenceRange,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      labResultId: json['labResultId'] ?? 0,
      labTestId: json['labTestId'] ?? 0,
      testName: json['testName'],
      resultValue: json['resultValue'] ?? '',
      unit: json['unit'],
      referenceRange: json['referenceRange'],
    );
  }
}

class Vaccination {
  final int vaccinationId;
  final String name;
  final String dateGiven;
  final String nextDue;

  Vaccination({
    required this.vaccinationId,
    required this.name,
    required this.dateGiven,
    required this.nextDue,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccinationId: json['vaccinationId'] ?? 0,
      name: json['name'] ?? '',
      dateGiven: json['dateGiven'] ?? '',
      nextDue: json['nextDue'] ?? '',
    );
  }
}
