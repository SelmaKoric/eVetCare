import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int paymentId;
  final int invoiceId;
  final double amount;
  final String paymentDate;
  final int? methodId;
  final String? methodName;

  Payment({
    required this.paymentId,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    this.methodId,
    this.methodName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] as int,
      invoiceId: json['invoiceId'] as int,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] ?? 0.0) as double,
      paymentDate: (json['paymentDate'] ?? '').toString(),
      methodId: json['methodId'] as int?,
      methodName: json['methodName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
