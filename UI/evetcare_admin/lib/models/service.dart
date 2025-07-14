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

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'] == null
          ? 0
          : (json['serviceId'] as num).toInt(),
      name: json['name'] == null ? 'undefined' : json['name'] as String,
      description: json['description'] == null
          ? 'undefined'
          : json['description'] as String,
      categoryId: json['categoryId'] == null
          ? 0
          : (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] == null
          ? 'undefined'
          : json['categoryName'] as String,
      price: json['price'] == null ? 0.0 : (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] == null
          ? 0
          : (json['durationMinutes'] as num).toInt(),
      isDeleted: json['isDeleted'] == null ? false : json['isDeleted'] as bool,
    );
  }
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
