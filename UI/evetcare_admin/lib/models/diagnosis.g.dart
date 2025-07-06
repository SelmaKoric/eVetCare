// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) => Diagnosis(
  diagnosisId: (json['diagnosisId'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$DiagnosisToJson(Diagnosis instance) => <String, dynamic>{
  'diagnosisId': instance.diagnosisId,
  'description': instance.description,
};
