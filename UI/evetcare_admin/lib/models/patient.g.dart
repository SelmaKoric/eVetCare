// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
  petId: (json['petId'] as num?)?.toInt(),
  name: json['name'] as String?,
  ownerName: json['ownerName'] as String?,
  species: json['species'] as String?,
  breed: json['breed'] as String?,
  genderName: json['genderName'] as String?,
  age: (json['age'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  photoUrl: json['photoUrl'] as String?,
  ownerPhoneNumber: json['ownerPhoneNumber'] as String?,
  ownerEmail: json['ownerEmail'] as String?,
);

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
  'petId': instance.petId,
  'name': instance.name,
  'ownerName': instance.ownerName,
  'species': instance.species,
  'breed': instance.breed,
  'genderName': instance.genderName,
  'age': instance.age,
  'weight': instance.weight,
  'photoUrl': instance.photoUrl,
  'ownerPhoneNumber': instance.ownerPhoneNumber,
  'ownerEmail': instance.ownerEmail,
};
