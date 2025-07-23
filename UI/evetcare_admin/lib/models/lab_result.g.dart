// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabResult _$LabResultFromJson(Map<String, dynamic> json) => LabResult(
  labResultId: (json['labResultId'] as num).toInt(),
  labTestId: (json['labTestId'] as num).toInt(),
  testName: json['testName'] as String?,
  resultValue: json['resultValue'] as String,
  unit: json['unit'] as String?,
  referenceRange: json['referenceRange'] as String?,
);

Map<String, dynamic> _$LabResultToJson(LabResult instance) => <String, dynamic>{
  'labResultId': instance.labResultId,
  'labTestId': instance.labTestId,
  'testName': instance.testName,
  'resultValue': instance.resultValue,
  'unit': instance.unit,
  'referenceRange': instance.referenceRange,
};
