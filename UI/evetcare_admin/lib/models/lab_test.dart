import 'package:json_annotation/json_annotation.dart';

part 'lab_test.g.dart';

@JsonSerializable()
class LabTest {
  final int? labTestId;
  final String? name;
  final String? unit;
  final String? referenceRange;

  LabTest({this.labTestId, this.name, this.unit, this.referenceRange});

  factory LabTest.fromJson(Map<String, dynamic> json) {
    print('LabTest.fromJson called with: $json');
    return _$LabTestFromJson(json);
  }
  Map<String, dynamic> toJson() => _$LabTestToJson(this);

  @override
  String toString() {
    return '$name${unit != null ? ' ($unit)' : ''}';
  }
}
