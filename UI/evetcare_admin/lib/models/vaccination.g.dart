// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vaccination _$VaccinationFromJson(Map<String, dynamic> json) => Vaccination(
  vaccinationId: (json['vaccinationId'] as num).toInt(),
  name: json['name'] as String,
  dateGiven: DateTime.parse(json['dateGiven'] as String),
  nextDue: DateTime.parse(json['nextDue'] as String),
);

Map<String, dynamic> _$VaccinationToJson(Vaccination instance) =>
    <String, dynamic>{
      'vaccinationId': instance.vaccinationId,
      'name': instance.name,
      'dateGiven': instance.dateGiven.toIso8601String(),
      'nextDue': instance.nextDue.toIso8601String(),
    };
