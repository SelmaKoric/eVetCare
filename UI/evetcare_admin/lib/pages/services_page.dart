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
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late ServiceProvider _serviceProvider;
  late Future<SearchResult<Service>> _futureServices;
  String _searchQuery = '';
  int _page = 1;
  final int _pageSize = 10;

  final TextEditingController _searchController = TextEditingController();

  // Category filter state
  List<ServiceCategory> _categories = [];
  ServiceCategory? _selectedCategory;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _serviceProvider = ServiceProvider();
    _fetchCategories();
    _fetchServices();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
    });
    try {
      final cats = await _serviceProvider.getServiceCategories();
      print('ServicesPage - Categories fetched: ${cats.length}');
      print(
        'ServicesPage - Categories: ${cats.map((c) => '${c.categoryId}: ${c.name}').join(', ')}',
      );
      setState(() {
        _categories = cats;
        _loadingCategories = false;
      });
    } catch (e) {
      print('ServicesPage - Error fetching categories: $e');
      setState(() {
        _categories = [];
        _loadingCategories = false;
      });
    }
  }

  void _fetchServices() {
    setState(() {
      final filter = <String, dynamic>{'page': _page, 'pageSize': _pageSize};
      if (_searchQuery.isNotEmpty) {
        filter['Name'] = _searchQuery;
      }
      // Always filter for active services
      filter['IsActive'] = true;
      _futureServices = _serviceProvider.get(filter: filter);
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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _page = 1;
    });
    _fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _serviceProvider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearch(),
          Expanded(
            child: Column(children: [_buildTable(), _buildPagination()]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Services",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearch(),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _clearFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AddServiceDialog(),
                  );
                  if (result == true) {
                    _fetchServices();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Service"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AB7E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1.2),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: double.infinity,
          child: FutureBuilder<SearchResult<Service>>(
            future: _futureServices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
                return const Center(child: Text('No services found.'));
              }
              final services = snapshot.data!.result;
              return DataTable(
                columnSpacing: 12,
                horizontalMargin: 8,
                headingRowHeight: 56,
                dataRowMinHeight: 48,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Duration',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: services.map((service) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Flexible(
                          child: Text(
                            service.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            service.description ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            service.categoryName ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${service.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          service.durationMinutes == null
                              ? '—'
                              : service.durationMinutes! == 0
                              ? '0m'
                              : service.durationMinutes! >= 60
                              ? '${(service.durationMinutes! / 60).round()}h ${service.durationMinutes! % 60 > 0 ? '${service.durationMinutes! % 60}m' : ''}'
                              : '${service.durationMinutes}m',
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () async {
                            // Ensure categories are loaded before opening dialog
                            if (_categories.isEmpty) {
                              await _fetchCategories();
                            }

                            print('Categories loaded: ${_categories.length}');
                            print(
                              'Categories: ${_categories.map((c) => '${c.categoryId}: ${c.name}').join(', ')}',
                            );

                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) =>
                                  EditServiceDialog(service: service),
                            );
                            if (result == true) {
                              _fetchServices();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: const Color(0xFF5AB7E2),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Edit"),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return FutureBuilder<SearchResult<Service>>(
      future: _futureServices,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.count == 0) {
          return Container();
        }
        final count = snapshot.data!.count;
        final totalPages = (count / _pageSize).ceil();
        if (totalPages == 0) {
          return Container();
        }
        int startPage = (_page - 2).clamp(1, totalPages);
        int endPage = (_page + 2).clamp(1, totalPages);
        if (endPage - startPage < 4) {
          if (startPage == 1) {
            endPage = (startPage + 4).clamp(1, totalPages);
          } else if (endPage == totalPages) {
            startPage = (endPage - 4).clamp(1, totalPages);
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _page > 1 ? () => _onPageChanged(_page - 1) : null,
              ),
              if (startPage > 1) ...[
                TextButton(
                  onPressed: () => _onPageChanged(1),
                  child: const Text('1'),
                ),
                if (startPage > 2) const Text('...'),
              ],
              for (int i = startPage; i <= endPage; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed: () => _onPageChanged(i),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (i == _page) {
                            return const Color(0xFF5AB7E2).withOpacity(0.2);
                          }
                          return Colors.transparent;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: i == _page
                              ? BorderSide(
                                  color: Theme.of(context).primaryColor,
                                )
                              : BorderSide.none,
                        ),
                      ),
                    ),
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontWeight: i == _page
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: i == _page
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                ),
              if (endPage < totalPages) ...[
                if (endPage < totalPages - 1) const Text('...'),
                TextButton(
                  onPressed: () => _onPageChanged(totalPages),
                  child: Text('$totalPages'),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _page < totalPages
                    ? () => _onPageChanged(_page + 1)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddServiceDialog extends StatefulWidget {
  const AddServiceDialog({super.key});

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

class EditServiceDialog extends StatefulWidget {
  final Service service;
  const EditServiceDialog({super.key, required this.service});

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  bool _loading = false;
  String? _error;

  final _priceFocus = FocusNode();
  final _durationFocus = FocusNode();

  List<ServiceCategory> _categories = [];
  ServiceCategory? _selectedCategory;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _priceController = TextEditingController(
      text: widget.service.price?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.service.durationMinutes?.toString() ?? '',
    );

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final provider = ServiceProvider();
      final cats = await provider.getServiceCategories();
      print('EditServiceDialog - Categories fetched: ${cats.length}');
      print(
        'EditServiceDialog - Categories: ${cats.map((c) => '${c.categoryId}: ${c.name}').join(', ')}',
      );

      setState(() {
        _categories = cats;
        _loadingCategories = false;
      });

      // Find the matching category for this service
      if (_categories.isNotEmpty) {
        try {
          _selectedCategory = _categories.firstWhere(
            (cat) => cat.categoryId == widget.service.categoryId,
            orElse: () => _categories.first,
          );
          print(
            'EditServiceDialog - Selected category: ${_selectedCategory?.name}',
          );
        } catch (e) {
          _selectedCategory = _categories.first;
          print(
            'EditServiceDialog - Using first category as fallback: ${_selectedCategory?.name}',
          );
        }
        setState(() {}); // Trigger rebuild to show selected category
      } else {
        _selectedCategory = null;
        print('EditServiceDialog - No categories available');
      }
    } catch (e) {
      print('EditServiceDialog - Error fetching categories: $e');
      setState(() {
        _loadingCategories = false;
      });
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = Authorization.token;
      final response = await http.put(
        Uri.parse('http://localhost:5081/Services/${widget.service.serviceId}'),
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
      title: const Text('Edit Service'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              _loadingCategories
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<ServiceCategory>(
                      value: _selectedCategory,
                      items: _categories.isEmpty
                          ? [
                              DropdownMenuItem(
                                value: null,
                                child: Text('No categories available'),
                              ),
                            ]
                          : _categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat.name),
                                  ),
                                )
                                .toList(),
                      onChanged: _categories.isEmpty
                          ? null
                          : (cat) => setState(() => _selectedCategory = cat),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
