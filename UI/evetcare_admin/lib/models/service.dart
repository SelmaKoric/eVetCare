import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int serviceId;
  final String name;
  final String? description;
  final int? categoryId;
  @JsonKey(defaultValue: '')
  final String? categoryName;
  final double? price;
  final int? durationMinutes;
  final bool? isActive;

  Service({
    required this.serviceId,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.price,
    this.durationMinutes,
    this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
