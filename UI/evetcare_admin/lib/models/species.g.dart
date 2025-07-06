// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Species _$SpeciesFromJson(Map<String, dynamic> json) => Species(
  speciesId: (json['speciesId'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$SpeciesToJson(Species instance) => <String, dynamic>{
  'speciesId': instance.speciesId,
  'name': instance.name,
};
