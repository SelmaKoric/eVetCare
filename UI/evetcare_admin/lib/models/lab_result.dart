import 'package:json_annotation/json_annotation.dart';

part 'lab_result.g.dart';

@JsonSerializable()
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

  factory LabResult.fromJson(Map<String, dynamic> json) =>
      _$LabResultFromJson(json);
  Map<String, dynamic> toJson() => _$LabResultToJson(this);
}
