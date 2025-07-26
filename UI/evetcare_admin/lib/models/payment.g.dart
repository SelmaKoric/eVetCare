// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  paymentId: (json['paymentId'] as num).toInt(),
  invoiceId: (json['invoiceId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  paymentDate: json['paymentDate'] as String,
  methodId: (json['methodId'] as num?)?.toInt(),
  methodName: json['methodName'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'invoiceId': instance.invoiceId,
  'amount': instance.amount,
  'paymentDate': instance.paymentDate,
  'methodId': instance.methodId,
  'methodName': instance.methodName,
};
