import 'package:json_annotation/json_annotation.dart';

part 'genders.g.dart';

@JsonSerializable()
class Gender {
  final int? genderId;
  final String? name;

  Gender({this.genderId, this.name});

  factory Gender.fromJson(Map<String, dynamic> json) => _$GenderFromJson(json);
  Map<String, dynamic> toJson() => _$GenderToJson(this);
}