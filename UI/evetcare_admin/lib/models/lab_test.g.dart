// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabTest _$LabTestFromJson(Map<String, dynamic> json) => LabTest(
  labTestId: (json['labTestId'] as num?)?.toInt(),
  name: json['name'] as String?,
  unit: json['unit'] as String?,
  referenceRange: json['referenceRange'] as String?,
);

Map<String, dynamic> _$LabTestToJson(LabTest instance) => <String, dynamic>{
  'labTestId': instance.labTestId,
  'name': instance.name,
  'unit': instance.unit,
  'referenceRange': instance.referenceRange,
};
