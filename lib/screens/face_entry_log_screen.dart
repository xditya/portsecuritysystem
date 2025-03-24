import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:portsecuritysystem/config/theme.dart';

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
    final status = entry['status'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child:
                        const Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateTime,
                          style: const TextStyle(
                            color: AppTheme.subtleTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == 'Present'
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status == 'Present'
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (confidence != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Confidence: $confidence',
                        style: const TextStyle(
                          color: AppTheme.subtleTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
                    hintText: 'Search by name',
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.subtleTextColor),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            style: const TextStyle(color: AppTheme.textColor),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: AppTheme.subtleTextColor),
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
