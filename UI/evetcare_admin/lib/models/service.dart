import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int serviceId;
  final String name;
  final String description;
  final int categoryId;
  final String categoryName;
  final double? price;
  final int? durationMinutes;
  final bool isDeleted;

  Service({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.price,
    this.durationMinutes,
    required this.isDeleted,
  });

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
