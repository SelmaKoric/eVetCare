import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/search_result.dart';
import '../providers/service_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/authorization.dart';
import '../models/service_category.dart';
import 'package:flutter/services.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late ServiceProvider _serviceProvider;
  late Future<SearchResult<Service>> _futureServices;
  String _searchQuery = '';
  int _page = 1;
  int _pageSize = 10;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serviceProvider = ServiceProvider();
    _fetchServices();
  }

  void _fetchServices() {
    setState(() {
      _futureServices = _serviceProvider.get(
        filter: {'search': _searchQuery, 'page': _page, 'pageSize': _pageSize},
      );
    });
  }

  void _onSearch() {
    _page = 1;
    _searchQuery = _searchController.text.trim();
    _fetchServices();
  }

  void _onPageChanged(int newPage) {
    _page = newPage;
    _fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _serviceProvider,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const Text(
                    'Services',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AddServiceDialog(),
                    );
                    if (result == true) {
                      _fetchServices();
                    }
                  },
                  child: const Text('Add New Service'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<SearchResult<Service>>(
                future: _futureServices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.result.isEmpty) {
                    return const Center(child: Text('No services found.'));
                  }
                  final services = snapshot.data!.result;
                  final count = snapshot.data!.count;
                  final totalPages = (count / _pageSize).ceil();
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Price')),
                                DataColumn(label: Text('Duration')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: services.map((service) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(service.name)),
                                    DataCell(Text(service.description)),
                                    DataCell(
                                      Text(
                                        ' 24${service.price?.toStringAsFixed(2) ?? '0.00'}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        service.durationMinutes == null ||
                                                service.durationMinutes == 0
                                            ? '—'
                                            : service.durationMinutes! % 60 == 0
                                            ? '${(service.durationMinutes! / 60).round()}h'
                                            : '${service.durationMinutes}m',
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              // TODO: Implement edit functionality
                                            },
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirm Delete',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this service?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(false),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                // TODO: Implement delete functionality
                                              }
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _page > 1
                                ? () => _onPageChanged(_page - 1)
                                : null,
                          ),
                          Text(
                            'Page \\$_page of \\${totalPages == 0 ? 1 : totalPages}',
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _page < totalPages
                                ? () => _onPageChanged(_page + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
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

class AddServiceDialog extends StatefulWidget {
  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _loading = false;
  String? _error;

  final _priceFocus = FocusNode();
  final _durationFocus = FocusNode();

  List<ServiceCategory> _categories = [];
  ServiceCategory? _selectedCategory;
  bool _loadingCategories = true;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _priceFocus.dispose();
    _durationFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoryError = null;
    });
    try {
      final provider = ServiceProvider();
      final cats = await provider.getServiceCategories();
      setState(() {
        _categories = cats;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categoryError = e.toString();
        _loadingCategories = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = Authorization.token;
      final response = await http.post(
        Uri.parse('http://localhost:5081/Services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': 'text/plain',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categoryId': _selectedCategory!.categoryId,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'durationMinutes': int.tryParse(_durationController.text) ?? 0,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Service'),
      content: _loadingCategories
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _categoryError != null
          ? SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  _categoryError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    DropdownButtonFormField<ServiceCategory>(
                      value: _selectedCategory,
                      items: _categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat.name),
                            ),
                          )
                          .toList(),
                      onChanged: (cat) =>
                          setState(() => _selectedCategory = cat),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      focusNode: _priceFocus,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final value = double.tryParse(v);
                        if (value == null) return 'Enter a valid number';
                        if (value < 0) return 'Must be positive';
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*\.?[0-9]*'),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                      ),
                      keyboardType: TextInputType.number,
                      focusNode: _durationFocus,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final value = int.tryParse(v);
                        if (value == null) return 'Enter a valid integer';
                        if (value < 0) return 'Must be positive';
                        return null;
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading || _loadingCategories ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
