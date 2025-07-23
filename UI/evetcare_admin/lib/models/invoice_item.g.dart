// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => InvoiceItem(
  invoiceItemId: (json['invoiceItemId'] as num).toInt(),
  serviceId: (json['serviceId'] as num).toInt(),
);

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'invoiceItemId': instance.invoiceItemId,
      'serviceId': instance.serviceId,
    };
