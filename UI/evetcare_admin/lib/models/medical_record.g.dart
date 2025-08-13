// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalRecord _$MedicalRecordFromJson(Map<String, dynamic> json) =>
    MedicalRecord(
      medicalRecordId: (json['medicalRecordId'] as num).toInt(),
      petId: (json['petId'] as num).toInt(),
      petName: json['petName'] as String?,
      appointmentId: (json['appointmentId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      analysisProvided: json['analysisProvided'] as String?,
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
          .toList(),
      treatments: (json['treatments'] as List<dynamic>)
          .map((e) => Treatment.fromJson(e as Map<String, dynamic>))
          .toList(),
      labResults: (json['labResults'] as List<dynamic>)
          .map((e) => LabResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      vaccinations: (json['vaccinations'] as List<dynamic>)
          .map((e) => Vaccination.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MedicalRecordToJson(MedicalRecord instance) =>
    <String, dynamic>{
      'medicalRecordId': instance.medicalRecordId,
      'petId': instance.petId,
      'petName': instance.petName,
      'appointmentId': instance.appointmentId,
      'date': instance.date.toIso8601String(),
      'notes': instance.notes,
      'analysisProvided': instance.analysisProvided,
      'diagnoses': instance.diagnoses,
      'treatments': instance.treatments,
      'labResults': instance.labResults,
      'vaccinations': instance.vaccinations,
    };
