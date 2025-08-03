import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/authorization.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/service.dart';
import '../models/disease_frequency.dart';
import '../models/most_common_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  // Revenue data
  double _totalRevenue = 0.0;
  Map<String, double> _serviceRevenue = {};
  Map<String, int> _paymentMethods = {};
  List<Invoice> _invoices = [];
  Map<int, String> _serviceNames = {}; // Cache for service names

  // Analytics data
  List<DiseaseFrequency> _diseaseFrequency = [];
  List<MostCommonService> _mostCommonServices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load service names first
      await _loadServiceNames();
      // Then load revenue data
      await _loadRevenueData();
      // Load analytics data
      await _loadAnalyticsData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadServiceNames() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5081/Services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> result = data['result'] ?? [];

        for (final serviceJson in result) {
          final service = Service.fromJson(serviceJson);
          _serviceNames[service.serviceId] = service.name;
        }
      }
    } catch (e) {
      print('Error loading service names: $e');
    }
  }

  Future<void> _loadRevenueData() async {
    try {
      // Fetch invoices for the date range
      final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

      print('Fetching invoices for date range: $startDateStr to $endDateStr');

      final response = await http.get(
        Uri.parse(
          'http://localhost:5081/Invoice?issueDateFrom=$startDateStr&issueDateTo=$endDateStr',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
      );

      print('Invoice API response status: ${response.statusCode}');
      print('Invoice API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> result = data['result'] ?? [];

        // Parse all invoices first
        final allInvoices = result.map((e) => Invoice.fromJson(e)).toList();

        // Filter by date range on client side as fallback
        _invoices = allInvoices.where((invoice) {
          try {
            final issueDate = DateTime.parse(invoice.issueDate.split('T')[0]);
            return issueDate.isAfter(
                  _startDate.subtract(const Duration(days: 1)),
                ) &&
                issueDate.isBefore(_endDate.add(const Duration(days: 1)));
          } catch (e) {
            print('Error parsing invoice date: ${invoice.issueDate}');
            return false;
          }
        }).toList();

        print(
          'Loaded ${allInvoices.length} total invoices, filtered to ${_invoices.length} invoices in date range',
        );
        await _calculateRevenue();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load revenue data: ${e.toString()}')),
      );
    }
  }

  Future<void> _calculateRevenue() async {
    _totalRevenue = 0.0;
    _serviceRevenue.clear();
    _paymentMethods.clear();

    for (final invoice in _invoices) {
      _totalRevenue += invoice.totalAmount;

      // Calculate service revenue (simplified - using invoice items)
      for (final item in invoice.invoiceItems) {
        final serviceName = _getServiceName(item.serviceId);
        // Use a portion of the total amount for each service
        // This is a simplified approach - ideally we'd have individual service prices
        final serviceAmount = invoice.totalAmount / invoice.invoiceItems.length;
        _serviceRevenue[serviceName] =
            (_serviceRevenue[serviceName] ?? 0.0) + serviceAmount;
      }
    }

    // Fetch payment methods data
    await _fetchPaymentMethods();
  }

  String _getServiceName(int serviceId) {
    return _serviceNames[serviceId] ?? 'Service #$serviceId';
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

      print('Fetching payments for date range: $startDateStr to $endDateStr');

      // Fetch payments for the entire date range
      final response = await http.get(
        Uri.parse(
          'http://localhost:5081/Payment?paymentDateFrom=$startDateStr&paymentDateTo=$endDateStr',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
      );

      print('Payment API response status: ${response.statusCode}');
      print('Payment API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> result = data['result'] ?? [];

        // Parse all payments first
        final allPayments = result
            .map((e) => Payment.fromJson(e as Map<String, dynamic>))
            .toList();

        // Filter by date range on client side as fallback
        final filteredPayments = allPayments.where((payment) {
          try {
            final paymentDate = DateTime.parse(
              payment.paymentDate.split('T')[0],
            );
            return paymentDate.isAfter(
                  _startDate.subtract(const Duration(days: 1)),
                ) &&
                paymentDate.isBefore(_endDate.add(const Duration(days: 1)));
          } catch (e) {
            print('Error parsing payment date: ${payment.paymentDate}');
            return false;
          }
        }).toList();

        for (final payment in filteredPayments) {
          final method = payment.methodId == 1 ? 'Cash' : 'Card';
          _paymentMethods[method] = (_paymentMethods[method] ?? 0) + 1;
        }

        print(
          'Loaded ${allPayments.length} total payments, filtered to ${filteredPayments.length} payments in date range',
        );
        print('Loaded payment methods: $_paymentMethods');
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
    }
  }

  Future<void> _loadAnalyticsData() async {
    try {
      print('Loading analytics data...');
      // Load disease frequency data
      await _loadDiseaseFrequency();
      // Load most common services data
      await _loadMostCommonServices();
      print('Analytics data loaded successfully');
    } catch (e) {
      print('Error loading analytics data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load analytics data: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _loadDiseaseFrequency() async {
    try {
      print('Fetching disease frequency data...');
      final response = await http.get(
        Uri.parse('http://localhost:5081/api/Analytics/disease-frequency'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
      );

      print('Disease frequency API response status: ${response.statusCode}');
      print('Disease frequency API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _diseaseFrequency = data
            .map((e) => DiseaseFrequency.fromJson(e as Map<String, dynamic>))
            .toList();

        print('Loaded ${_diseaseFrequency.length} disease frequency records');
        print(
          'Disease frequency data: ${_diseaseFrequency.map((d) => '${d.diagnosisName}: ${d.occurrence}').join(', ')}',
        );
      } else {
        print(
          'Failed to load disease frequency: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error loading disease frequency: $e');
    }

    // Add some test data if no data was loaded
    if (_diseaseFrequency.isEmpty) {
      print('Adding test disease frequency data for PDF testing');
      _diseaseFrequency = [
        DiseaseFrequency(
          diagnosisId: 1,
          diagnosisName: 'Test Disease 1',
          occurrence: 5,
        ),
        DiseaseFrequency(
          diagnosisId: 2,
          diagnosisName: 'Test Disease 2',
          occurrence: 3,
        ),
      ];
    }
  }

  Future<void> _loadMostCommonServices() async {
    try {
      print('Fetching most common services data...');
      final response = await http.get(
        Uri.parse('http://localhost:5081/api/Analytics/most-common-services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Authorization.token}',
          'accept': 'text/plain',
        },
      );

      print('Most common services API response status: ${response.statusCode}');
      print('Most common services API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _mostCommonServices = data
            .map((e) => MostCommonService.fromJson(e as Map<String, dynamic>))
            .toList();

        print(
          'Loaded ${_mostCommonServices.length} most common services records',
        );
        print(
          'Most common services data: ${_mostCommonServices.map((s) => '${s.serviceName}: ${s.usageCount}').join(', ')}',
        );
      } else {
        print(
          'Failed to load most common services: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error loading most common services: $e');
    }

    // Add some test data if no data was loaded
    if (_mostCommonServices.isEmpty) {
      print('Adding test most common services data for PDF testing');
      _mostCommonServices = [
        MostCommonService(
          serviceId: 1,
          serviceName: 'Test Service 1',
          usageCount: 10,
        ),
        MostCommonService(
          serviceId: 2,
          serviceName: 'Test Service 2',
          usageCount: 7,
        ),
      ];
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loading data for ${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Reload data with new date range
      _loadData();
    }
  }

  List<PieChartSectionData> _getPaymentChartData() {
    final totalPayments = _paymentMethods.values.fold(
      0,
      (sum, count) => sum + count,
    );

    if (totalPayments == 0) return [];

    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.red];
    int colorIndex = 0;

    return _paymentMethods.entries.map((entry) {
      final percentage = (entry.value / totalPayments) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Future<void> _exportToPDF() async {
    try {
      // Debug logging for analytics data
      print('Exporting PDF with analytics data:');
      print('Disease frequency records: ${_diseaseFrequency.length}');
      print('Most common services records: ${_mostCommonServices.length}');
      print(
        'Disease frequency data: ${_diseaseFrequency.map((d) => '${d.diagnosisName}: ${d.occurrence}').join(', ')}',
      );
      print(
        'Most common services data: ${_mostCommonServices.map((s) => '${s.serviceName}: ${s.usageCount}').join(', ')}',
      );

      final pdf = pw.Document();

      // Create a simpler, more reliable PDF structure
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'eVetCare Analytics Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Date Range
                  pw.Text(
                    'Period: ${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 30),

                  // Total Revenue Section
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.green, width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                      color: PdfColors.green50,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Revenue',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '\$${_totalRevenue.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                        pw.Text(
                          'Generated from ${_invoices.length} invoices',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Disease Frequency Section
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.purple, width: 1),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Disease Frequency',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        if (_diseaseFrequency.isEmpty)
                          pw.Text(
                            'No disease frequency data available',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey600,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          )
                        else
                          ..._diseaseFrequency
                              .take(5)
                              .map(
                                (disease) => pw.Container(
                                  margin: pw.EdgeInsets.only(bottom: 5),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          disease.diagnosisName,
                                          style: pw.TextStyle(
                                            fontSize: 14,
                                            fontWeight: pw.FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      pw.Text(
                                        '${disease.occurrence} occurrences',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Most Common Services Section
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.teal, width: 1),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Most Common Services',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        if (_mostCommonServices.isEmpty)
                          pw.Text(
                            'No service usage data available',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey600,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          )
                        else
                          ..._mostCommonServices
                              .take(5)
                              .map(
                                (service) => pw.Container(
                                  margin: pw.EdgeInsets.only(bottom: 5),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          service.serviceName,
                                          style: pw.TextStyle(
                                            fontSize: 14,
                                            fontWeight: pw.FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      pw.Text(
                                        '${service.usageCount} uses',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  // Footer
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'Report generated on ${DateFormat('MMM dd, yyyy at HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save the PDF to downloads folder (platform-agnostic)
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        // Fallback to documents directory if downloads is not available
        final documentsDir = await getApplicationDocumentsDirectory();
        final file = File(
          '${documentsDir.path}/eVetCare_Analytics_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
        );
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exported to Documents: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        final file = File(
          '${downloadsDir.path}/eVetCare_Analytics_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
        );
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exported to Downloads: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Analytics Report',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5AB7E2),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _exportToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AB7E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Color(0xFF5AB7E2),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    icon: Icon(Icons.attach_money, size: 20),
                    text: 'Revenue',
                  ),
                  Tab(icon: Icon(Icons.analytics, size: 20), text: 'Analytics'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: TabBarView(
                  children: [
                    // Revenue Tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildRevenueCard(),
                          const SizedBox(height: 24),
                          _buildServiceRevenueCard(),
                          const SizedBox(height: 24),
                          _buildPaymentMethodsCard(),
                        ],
                      ),
                    ),
                    // Analytics Tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildDiseaseFrequencyCard(),
                          const SizedBox(height: 24),
                          _buildMostCommonServicesCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, size: 32, color: Colors.green[700]),
                const SizedBox(width: 12),
                const Text(
                  'Total Revenue',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${_totalRevenue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                '${_invoices.length} invoices processed',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRevenueCard() {
    final sortedServices = _serviceRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Text(
                  'Revenue by Service',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedServices.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'No service data available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...sortedServices
                  .take(5)
                  .map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    final totalPayments = _paymentMethods.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, size: 32, color: Colors.orange[700]),
                const SizedBox(width: 12),
                const Text(
                  'Payment Methods',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_paymentMethods.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'No payment data available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Pie Chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _getPaymentChartData(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Payment Methods List
              ..._paymentMethods.entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${entry.value} transactions (${totalPayments > 0 ? ((entry.value / totalPayments) * 100).toStringAsFixed(1) : 0}%)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseFrequencyCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  size: 32,
                  color: Colors.purple[700],
                ),
                const SizedBox(width: 12),
                const Text(
                  'Disease Frequency',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_diseaseFrequency.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'No disease frequency data available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._diseaseFrequency
                  .take(5)
                  .map(
                    (disease) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              disease.diagnosisName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[700],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${disease.occurrence} occurrences',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostCommonServicesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, size: 32, color: Colors.teal[700]),
                const SizedBox(width: 12),
                const Text(
                  'Most Common Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_mostCommonServices.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'No service usage data available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._mostCommonServices
                  .take(5)
                  .map(
                    (service) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.serviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${service.usageCount} uses',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
