import 'package:json_annotation/json_annotation.dart';

part 'most_common_service.g.dart';

@JsonSerializable()
class MostCommonService {
  final int serviceId;
  final String serviceName;
  final int usageCount;

  MostCommonService({
    required this.serviceId,
    required this.serviceName,
    required this.usageCount,
  });

  factory MostCommonService.fromJson(Map<String, dynamic> json) =>
      _$MostCommonServiceFromJson(json);

  Map<String, dynamic> toJson() => _$MostCommonServiceToJson(this);
} 