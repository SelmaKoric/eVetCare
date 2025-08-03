// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'most_common_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MostCommonService _$MostCommonServiceFromJson(Map<String, dynamic> json) =>
    MostCommonService(
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String,
      usageCount: (json['usageCount'] as num).toInt(),
    );

Map<String, dynamic> _$MostCommonServiceToJson(MostCommonService instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'usageCount': instance.usageCount,
    };
