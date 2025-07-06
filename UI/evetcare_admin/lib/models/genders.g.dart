// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gender _$GenderFromJson(Map<String, dynamic> json) => Gender(
  genderId: (json['genderId'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$GenderToJson(Gender instance) => <String, dynamic>{
  'genderId': instance.genderId,
  'name': instance.name,
};
