import 'package:json_annotation/json_annotation.dart';

part 'vaccination.g.dart';

@JsonSerializable()
class Vaccination {
  final int vaccinationId;
  final String name;
  final DateTime dateGiven;
  final DateTime nextDue;

  Vaccination({
    required this.vaccinationId,
    required this.name,
    required this.dateGiven,
    required this.nextDue,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) =>
      _$VaccinationFromJson(json);
  Map<String, dynamic> toJson() => _$VaccinationToJson(this);
}
