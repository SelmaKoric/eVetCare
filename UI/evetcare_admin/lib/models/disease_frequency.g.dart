// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disease_frequency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiseaseFrequency _$DiseaseFrequencyFromJson(Map<String, dynamic> json) =>
    DiseaseFrequency(
      diagnosisId: (json['diagnosisId'] as num).toInt(),
      diagnosisName: json['diagnosisName'] as String,
      occurrence: (json['occurrence'] as num).toInt(),
    );

Map<String, dynamic> _$DiseaseFrequencyToJson(DiseaseFrequency instance) =>
    <String, dynamic>{
      'diagnosisId': instance.diagnosisId,
      'diagnosisName': instance.diagnosisName,
      'occurrence': instance.occurrence,
    };
