// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Treatment _$TreatmentFromJson(Map<String, dynamic> json) => Treatment(
  treatmentId: (json['treatmentId'] as num).toInt(),
  treatmentDescription: json['treatmentDescription'] as String,
);

Map<String, dynamic> _$TreatmentToJson(Treatment instance) => <String, dynamic>{
  'treatmentId': instance.treatmentId,
  'treatmentDescription': instance.treatmentDescription,
};
