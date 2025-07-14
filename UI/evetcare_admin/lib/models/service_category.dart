import 'package:json_annotation/json_annotation.dart';

part 'service_category.g.dart';

@JsonSerializable()
class ServiceCategory {
  final int categoryId;
  final String name;
  final bool isDeleted;

  ServiceCategory({
    required this.categoryId,
    required this.name,
    required this.isDeleted,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      _$ServiceCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceCategoryToJson(this);
}
