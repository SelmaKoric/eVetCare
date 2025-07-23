// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
  serviceId: (json['serviceId'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  categoryId: (json['categoryId'] as num?)?.toInt(),
  categoryName: json['categoryName'] as String? ?? '',
  price: (json['price'] as num?)?.toDouble(),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
  'serviceId': instance.serviceId,
  'name': instance.name,
  'description': instance.description,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'price': instance.price,
  'durationMinutes': instance.durationMinutes,
  'isActive': instance.isActive,
};
