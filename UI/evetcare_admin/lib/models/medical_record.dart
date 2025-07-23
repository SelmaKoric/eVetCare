import 'package:json_annotation/json_annotation.dart';
import 'diagnosis.dart';
import 'treatment.dart';
import 'lab_result.dart';
import 'vaccination.dart';

part 'medical_record.g.dart';

@JsonSerializable()
class MedicalRecord {
  final int medicalRecordId;
  final int petId;
  final String petName;
  final int appointmentId;
  final DateTime date;
  final String? notes;
  final String? analysisProvided;
  final List<Diagnosis> diagnoses;
  final List<Treatment> treatments;
  final List<LabResult> labResults;
  final List<Vaccination> vaccinations;

  MedicalRecord({
    required this.medicalRecordId,
    required this.petId,
    required this.petName,
    required this.appointmentId,
    required this.date,
    this.notes,
    this.analysisProvided,
    required this.diagnoses,
    required this.treatments,
    required this.labResults,
    required this.vaccinations,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
    medicalRecordId: json['medicalRecordId'] as int,
    petId: json['petId'] as int,
    petName: json['petName'] as String,
    appointmentId: json['appointmentId'] as int,
    date: DateTime.parse(json['date'] as String),
    notes: json['notes'] as String?,
    analysisProvided: json['analysisProvided'] as String?,
    diagnoses:
        (json['diagnoses'] as List<dynamic>?)
            ?.map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    treatments:
        (json['treatments'] as List<dynamic>?)
            ?.map((e) => Treatment.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    labResults:
        (json['labResults'] as List<dynamic>?)
            ?.map((e) => LabResult.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    vaccinations:
        (json['vaccinations'] as List<dynamic>?)
            ?.map((e) => Vaccination.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'medicalRecordId': medicalRecordId,
    'petId': petId,
    'petName': petName,
    'appointmentId': appointmentId,
    'date': date.toIso8601String(),
    'notes': notes,
    'analysisProvided': analysisProvided,
    'diagnoses': diagnoses.map((d) => d.toJson()).toList(),
    'treatments': treatments.map((t) => t.toJson()).toList(),
    'labResults': labResults.map((l) => l.toJson()).toList(),
    'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
  };
}
