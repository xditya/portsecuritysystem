import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FaceEntryLogScreen extends StatefulWidget {
  const FaceEntryLogScreen({super.key});

  @override
  State<FaceEntryLogScreen> createState() => _FaceEntryLogScreenState();
}

class _FaceEntryLogScreenState extends State<FaceEntryLogScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _entryRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchEntryLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRecords() {
    setState(() {
      _filteredRecords = _entryRecords.where((record) {
        final searchTerm = _searchController.text.toLowerCase();

        bool matchesSearch = searchTerm.isEmpty ||
            record['name'].toString().toLowerCase().contains(searchTerm);

        bool matchesStatus =
            _selectedStatus == null || record['status'] == _selectedStatus;

        bool matchesDate = _selectedDate == null ||
            record['date'] == DateFormat('yyyy-MM-dd').format(_selectedDate!);

        return matchesSearch && matchesStatus && matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterRecords();
      });
    }
  }

  Future<void> _fetchEntryLogs() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/face-log'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _entryRecords =
              List<Map<String, dynamic>>.from(data['attendance_records']);
          _filteredRecords = _entryRecords;
          _isLoading = false;
        });
      } else {
        throw 'Failed to fetch face logs';
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDateTime(String date, String time) {
    final dateTime = DateTime.parse('$date $time');
    return DateFormat('MMM d, y • h:mm a').format(dateTime);
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final dateTime = _formatDateTime(entry['date'], entry['time']);
    final confidence = entry['confidence'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 24),
                const SizedBox(width: 8),
                Text(
                  entry['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry['status'] == 'Present'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry['status'],
                    style: TextStyle(
                      color: entry['status'] == 'Present'
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (confidence != null) ...[
              const SizedBox(height: 8),
              Text(
                'Confidence: $confidence',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              dateTime,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Entry Log'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchEntryLogs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterRecords();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => _filterRecords(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          hintText: 'Status',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Status'),
                          ),
                          ...['Present', 'Detected'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            _filterRecords();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat('MMM d, y').format(_selectedDate!),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedDate != null || _selectedStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Text('Filters: '),
                        if (_selectedStatus != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Chip(
                              label: Text(_selectedStatus!),
                              onDeleted: () {
                                setState(() {
                                  _selectedStatus = null;
                                  _filterRecords();
                                });
                              },
                            ),
                          ),
                        if (_selectedDate != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Chip(
                              label: Text(
                                  DateFormat('MMM d').format(_selectedDate!)),
                              onDeleted: () {
                                setState(() {
                                  _selectedDate = null;
                                  _filterRecords();
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                    ? const Center(
                        child: Text('No matching records found'),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchEntryLogs,
                        child: ListView.builder(
                          itemCount: _filteredRecords.length,
                          itemBuilder: (context, index) {
                            return _buildEntryCard(_filteredRecords[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
