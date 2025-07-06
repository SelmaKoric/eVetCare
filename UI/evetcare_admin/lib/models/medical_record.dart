import 'package:json_annotation/json_annotation.dart';
import 'diagnosis.dart';

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

  MedicalRecord({
    required this.medicalRecordId,
    required this.petId,
    required this.petName,
    required this.appointmentId,
    required this.date,
    this.notes,
    this.analysisProvided,
    required this.diagnoses,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) =>
      _$MedicalRecordFromJson(json);

  Map<String, dynamic> toJson() => _$MedicalRecordToJson(this);
}