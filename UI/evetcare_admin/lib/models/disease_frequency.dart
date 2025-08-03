import 'package:json_annotation/json_annotation.dart';

part 'disease_frequency.g.dart';

@JsonSerializable()
class DiseaseFrequency {
  final int diagnosisId;
  final String diagnosisName;
  final int occurrence;

  DiseaseFrequency({
    required this.diagnosisId,
    required this.diagnosisName,
    required this.occurrence,
  });

  factory DiseaseFrequency.fromJson(Map<String, dynamic> json) =>
      _$DiseaseFrequencyFromJson(json);

  Map<String, dynamic> toJson() => _$DiseaseFrequencyToJson(this);
} 