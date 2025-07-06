import 'package:evetcare_admin/models/patient.dart';
import 'package:evetcare_admin/models/search_result.dart';
import 'package:evetcare_admin/pages/add_patient_page.dart';
import 'package:evetcare_admin/pages/view_patient_page.dart';
import 'package:evetcare_admin/providers/patient_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late PatientProvider _patientProvider;
  SearchResult<Patient>? _result;
  final _searchController = TextEditingController();

  int _currentPage = 1;
  final int _pageSize = 8;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patientProvider = Provider.of<PatientProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _patientProvider.get(
        filter: {
          'NameOrOwnerName': _searchController.text,
          'Page': _currentPage.toString(),
          'PageSize': _pageSize.toString(),
        },
      );
      setState(() {
        _result = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    }
  }

  void _goToPage(int page) {
    if (page < 1) page = 1;
    if (_result != null && _result!.count > 0) {
      final totalPages = (_result!.count / _pageSize).ceil();
      if (page > totalPages) {
        page = totalPages;
      }
    }

    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearch(),
        Expanded(child: Column(children: [_buildTable(), _buildPagination()])),
      ],
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
                "Patients",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) {
                    _currentPage = 1;
                    _loadData();
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or owner',
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPatientPage()),
                  ).then((_) {
                    _loadData(); 
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Patient"),
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
          child: DataTable(
            columnSpacing: 12,
            horizontalMargin: 8,
            columns: const [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Owner")),
              DataColumn(label: Text("Species")),
              DataColumn(label: Text("Breed")),
              DataColumn(label: Text("Gender")),
              DataColumn(label: Text("Age")),
              DataColumn(label: Text("Actions")),
            ],
            rows:
                _result?.result.map((patient) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Flexible(
                          child: Text(
                            patient.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            patient.ownerName ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            patient.species ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            patient.breed ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            patient.genderName ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Flexible(
                          child: Text(
                            patient.age?.toString() ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewPatientPage(patient: patient),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: const Color(0xFF5AB7E2),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("View"),
                        ),
                      ),
                    ],
                  );
                }).toList() ??
                [],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_result == null || _result!.count == 0) {
      return Container();
    }

    final totalPages = (_result!.count / _pageSize).ceil();

    if (totalPages == 0) {
      return Container();
    }

    int startPage = (_currentPage - 2).clamp(1, totalPages);
    int endPage = (_currentPage + 2).clamp(1, totalPages);

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
            onPressed: _currentPage > 1
                ? () => _goToPage(_currentPage - 1)
                : null,
          ),
          if (startPage > 1) ...[
            TextButton(onPressed: () => _goToPage(1), child: const Text('1')),
            if (startPage > 2) const Text('...'),
          ],
          for (int i = startPage; i <= endPage; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextButton(
                onPressed: () => _goToPage(i),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (i == _currentPage) {
                      return Color(0xFF5AB7E2).withOpacity(0.2);
                    }
                    return Colors.transparent;
                  }),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: i == _currentPage
                          ? BorderSide(color: Theme.of(context).primaryColor)
                          : BorderSide.none,
                    ),
                  ),
                ),
                child: Text(
                  '$i',
                  style: TextStyle(
                    fontWeight: i == _currentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: i == _currentPage
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              ),
            ),
          if (endPage < totalPages) ...[
            if (endPage < totalPages - 1) const Text('...'),
            TextButton(
              onPressed: () => _goToPage(totalPages),
              child: Text('$totalPages'),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
