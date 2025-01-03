import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import 'add/addschedule.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _schedules = [];
  String _selectedDay = 'Today';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${Config.baseUrl}schedules'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _schedules = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load schedules');
        }
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSchedule(String id) async {
    try {
      if (id.isEmpty) throw Exception('Invalid schedule ID');

      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}schedules/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          await _loadSchedules();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to delete schedule');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateSchedule(String id, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      if (id.isEmpty) throw Exception('Invalid schedule ID');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}schedules/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          await _loadSchedules();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to update schedule');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.white)))
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 12),
                              _buildDaySelector(),
                              const SizedBox(height: 12),
                              _buildScheduleStats(),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildScheduleCard(_schedules[index]),
                            childCount: _schedules.length,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search schedule...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.4),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddSchedulePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Today', 'Tomorrow', 'Next Week', 'Next Month'].map((day) {
          final isSelected = _selectedDay == day;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.green : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                day,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleStats() {
    final totalSchedules = _schedules.length;
    final upcomingSchedules =
        _schedules.where((s) => s['status_schedule'] == 0).length;
    final completedSchedules =
        _schedules.where((s) => s['status_schedule'] == 1).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalSchedules.toString(), Icons.event),
          _buildStatItem(
              'Upcoming', upcomingSchedules.toString(), Icons.upcoming),
          _buildStatItem(
              'Completed', completedSchedules.toString(), Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['name_schedule'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildScheduleInfo(
                        Icons.calendar_today, schedule['date_schedule'] ?? ''),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: schedule['status_schedule'] == 0
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    schedule['status_schedule'] == 0 ? 'Upcoming' : 'Completed',
                    style: TextStyle(
                      color: schedule['status_schedule'] == 0
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
            color: const Color(0xFF1A1A1A),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (String value) async {
              if (value == 'edit') {
                await _showEditModal(schedule);
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Yakin ingin menghapus schedule ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Hapus',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final scheduleId = schedule['id_schedule']?.toString() ?? '';
                  await _deleteSchedule(scheduleId);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditModal(Map<String, dynamic> schedule) async {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: schedule['name_schedule']);
    DateTime? selectedDate = schedule['date_schedule'] != null
        ? DateTime.parse(schedule['date_schedule'])
        : null;
    int statusSchedule = schedule['status_schedule'] ?? 0;

    final scheduleId = schedule['id_schedule']?.toString() ?? '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Edit Schedule',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Schedule Name',
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF1E1E1E),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Schedule Date',
                            labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Select date',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: statusSchedule,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Upcoming')),
                          DropdownMenuItem(value: 1, child: Text('Completed')),
                        ],
                        onChanged: (value) =>
                            setState(() => statusSchedule = value ?? 0),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedDate != null) {
                      Navigator.pop(context, {
                        'name_schedule': nameController.text,
                        'date_schedule': selectedDate!.toIso8601String(),
                        'status_schedule': statusSchedule,
                      });
                    }
                  },
                  child:
                      const Text('Save', style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await _updateSchedule(scheduleId, result);
    }
  }

  Widget _buildScheduleInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
