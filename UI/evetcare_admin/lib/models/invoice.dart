import 'package:json_annotation/json_annotation.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

@JsonSerializable(explicitToJson: true)
class Invoice {
  final int invoiceId;
  final int appointmentId;
  final double totalAmount;
  final String issueDate;
  final List<InvoiceItem> invoiceItems;

  Invoice({
    required this.invoiceId,
    required this.appointmentId,
    required this.totalAmount,
    required this.issueDate,
    required this.invoiceItems,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}
