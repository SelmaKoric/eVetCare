// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  invoiceId: (json['invoiceId'] as num).toInt(),
  appointmentId: (json['appointmentId'] as num).toInt(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  issueDate: json['issueDate'] as String,
  invoiceItems: (json['invoiceItems'] as List<dynamic>)
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'invoiceId': instance.invoiceId,
  'appointmentId': instance.appointmentId,
  'totalAmount': instance.totalAmount,
  'issueDate': instance.issueDate,
  'invoiceItems': instance.invoiceItems.map((e) => e.toJson()).toList(),
};
