import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/search_result.dart';
import '../providers/invoice_provider.dart';
import '../models/service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/authorization.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late InvoiceProvider _invoiceProvider;
  late Future<SearchResult<Invoice>> _futureInvoices;
  Map<int, String> _serviceNames = {}; // serviceId -> name
  bool _loadingServices = false;

  @override
  void initState() {
    super.initState();
    _invoiceProvider = InvoiceProvider();
    _fetchInvoices();
  }

  void _fetchInvoices() {
    setState(() {
      _futureInvoices = _invoiceProvider.get();
    });
  }

  Future<void> _fetchServiceNamesForInvoices(List<Invoice> invoices) async {
    setState(() {
      _loadingServices = true;
    });
    final serviceIds = invoices
        .expand((inv) => inv.invoiceItems.map((item) => item.serviceId))
        .toSet();
    final Map<int, String> names = {};
    for (final id in serviceIds) {
      try {
        final headers = {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
          if (Authorization.token != null)
            'Authorization': 'Bearer ${Authorization.token}',
        };
        final response = await http.get(
          Uri.parse('http://localhost:5081/Services/$id'),
          headers: headers,
        );
        print('Service $id status: ${response.statusCode}');
        print('Service $id body: ${response.body}');
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          try {
            final service = Service.fromJson(data);
            names[id] = service.name;
          } catch (e) {
            print('Deserialization error for service $id: $e');
            names[id] = 'Unknown';
          }
        } else {
          names[id] = 'Unknown';
        }
      } catch (e) {
        print('Error fetching service $id: $e');
        names[id] = 'Unknown';
      }
    }
    setState(() {
      _serviceNames = names;
      _loadingServices = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _invoiceProvider,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Invoices',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<SearchResult<Invoice>>(
                future: _futureInvoices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \n${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.result.isEmpty) {
                    return const Center(child: Text('No invoices found.'));
                  }
                  final invoices = snapshot.data!.result;
                  // Fetch service names if not already loaded
                  if (_serviceNames.isEmpty && !_loadingServices) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _fetchServiceNamesForInvoices(invoices);
                    });
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Invoice ID')),
                      DataColumn(label: Text('Total Amount')),
                      DataColumn(label: Text('Issue Date')),
                      DataColumn(label: Text('Services')),
                    ],
                    rows: invoices.map((invoice) {
                      final serviceNames = invoice.invoiceItems
                          .map((item) => _serviceNames[item.serviceId])
                          .where(
                            (name) =>
                                name != null &&
                                name != 'Unknown' &&
                                name!.isNotEmpty,
                          )
                          .join(', ');
                      return DataRow(
                        cells: [
                          DataCell(Text(invoice.invoiceId.toString())),
                          DataCell(
                            Text(invoice.totalAmount.toStringAsFixed(2)),
                          ),
                          DataCell(Text(invoice.issueDate.split('T').first)),
                          DataCell(
                            Text(serviceNames.isNotEmpty ? serviceNames : '—'),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
