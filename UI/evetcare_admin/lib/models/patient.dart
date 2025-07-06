import 'package:json_annotation/json_annotation.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient {
  int? petId;
  String? name;
  String? ownerName;
  String? species;
  String? breed;
  String? genderName;
  int? age;
  double? weight;
  String? photoUrl;

  String? ownerPhoneNumber;
  String? ownerEmail;

  Patient({
    this.petId,
    this.name,
    this.ownerName,
    this.species,
    this.breed,
    this.genderName,
    this.age,
    this.weight,
    this.photoUrl,
    this.ownerPhoneNumber,
    this.ownerEmail,
  });

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  Map<String, dynamic> toJson() => _$PatientToJson(this);

}