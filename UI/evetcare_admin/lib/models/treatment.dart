import 'package:json_annotation/json_annotation.dart';

part 'treatment.g.dart';

@JsonSerializable()
class Treatment {
  final int treatmentId;
  final String treatmentDescription;

  Treatment({required this.treatmentId, required this.treatmentDescription});

  factory Treatment.fromJson(Map<String, dynamic> json) =>
      _$TreatmentFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentToJson(this);
}
