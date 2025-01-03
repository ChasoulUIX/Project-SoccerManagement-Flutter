import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import 'add/addassessment.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _assessments = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('${Config.baseUrl}assessments'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _assessments = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          debugPrint('Failed to load assessments: ${response.statusCode}');
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading assessments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAssessment(int id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token != null) {
        final response = await http.delete(
          Uri.parse('${Config.baseUrl}assessments/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success']) {
            await _loadAssessments();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(data['message'] ?? 'Assessment berhasil dihapus')),
            );
          }
        } else {
          debugPrint('Delete failed with status: ${response.statusCode}');
          throw Exception('Failed to delete assessment');
        }
      }
    } catch (e) {
      debugPrint('Error deleting assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus assessment')),
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
                          _buildCategoryFilter(),
                          const SizedBox(height: 12),
                          _buildAssessmentStats(),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildAssessmentCard(_assessments[index]),
                        childCount: _assessments.length,
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
                    hintText: 'Cari assessment...',
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
                      builder: (context) => const AddAssessmentPage(),
                      fullscreenDialog: false,
                      maintainState: true,
                    ),
                  ).then((_) => _loadAssessments());
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

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Technical', 'Physical', 'Tactical', 'Mental']
            .map((category) {
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.green : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                category,
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

  Widget _buildAssessmentStats() {
    final avgScore = _assessments.isEmpty
        ? 0.0
        : _assessments
                .map((a) => (a['score'] ?? 0) as num)
                .reduce((a, b) => a + b) /
            _assessments.length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Average', avgScore.toStringAsFixed(1)),
          _buildStatColumn('Total', _assessments.length.toString()),
          _buildStatColumn('Monthly', _getMonthlyCount().toString()),
        ],
      ),
    );
  }

  int _getMonthlyCount() {
    final now = DateTime.now();
    return _assessments.where((a) {
      if (a['date'] == null) return false;
      try {
        final date = DateTime.parse(a['date'].toString());
        return date.year == now.year && date.month == now.month;
      } catch (e) {
        return false;
      }
    }).length;
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    debugPrint('Assessment data: $assessment');

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      assessment['student_name'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${assessment['point']}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.category,
                        size: 12, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      assessment['category'] ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today,
                        size: 12, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      assessment['date'] ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  assessment['notes'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
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
                await _showEditModal(assessment);
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    title: const Text('Konfirmasi',
                        style: TextStyle(color: Colors.white)),
                    content: const Text('Yakin ingin menghapus assessment ini?',
                        style: TextStyle(color: Colors.white)),
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
                  final assessmentId =
                      assessment['id_assessment'] ?? assessment['id'];
                  if (assessmentId != null) {
                    await _deleteAssessment(int.parse(assessmentId.toString()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid assessment ID')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditModal(Map<String, dynamic> assessment) async {
    final assessmentId = assessment['id_assessment'] ?? assessment['id'];
    if (assessmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid assessment ID')),
      );
      return;
    }

    // Map aspect_sub IDs to category names
    final aspectToCategory = {
      1: 'Technical',
      2: 'Physical',
      3: 'Tactical',
      4: 'Mental',
    };

    // Initialize controllers with existing data
    final formKey = GlobalKey<FormState>();
    final scoreController = TextEditingController(
        text: (assessment['point'] ?? assessment['score'])?.toString() ?? '');
    final notesController = TextEditingController(
        text: assessment['ket'] ?? assessment['notes'] ?? '');

    // Convert aspect_sub ID to category name
    String selectedCategory = aspectToCategory[assessment['id_aspect_sub']] ??
        assessment['category'] ??
        'Technical';

    // Parse date from assessment
    DateTime selectedDate = assessment['date_assessment'] != null
        ? DateTime.parse(assessment['date_assessment'])
        : assessment['date'] != null
            ? DateTime.parse(assessment['date'])
            : DateTime.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Edit Assessment',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: scoreController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Score',
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
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        items: ['Technical', 'Physical', 'Tactical', 'Mental']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedCategory = value!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
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
                    if (formKey.currentState!.validate()) {
                      // Validate that score is a valid integer before parsing
                      if (scoreController.text.isEmpty ||
                          !RegExp(r'^\d+$').hasMatch(scoreController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter a valid score number')),
                        );
                        return;
                      }
                      Navigator.pop(context, {
                        'score': int.parse(scoreController.text),
                        'category': selectedCategory,
                        'notes': notesController.text,
                        'date': selectedDate.toIso8601String(),
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
      await _updateAssessment(assessmentId, result);
    }
  }

  Future<void> _updateAssessment(dynamic id, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      // Map category names to their corresponding IDs
      final categoryToId = {
        'Technical': 1,
        'Physical': 2,
        'Tactical': 3,
        'Mental': 4,
      };

      // Updated to match database column names and data types
      final updateData = {
        'point': data['score'],
        'id_aspect_sub':
            categoryToId[data['category']] ?? 1, // Convert category name to ID
        'ket': data['notes'],
        'date_assessment': data['date'],
      };

      debugPrint('Updating assessment $id with data: $updateData');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}assessments/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      debugPrint('Update response status: ${response.statusCode}');
      debugPrint('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          await _loadAssessments();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ??
                    'Assessment berhasil diperbarui')),
          );
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal memperbarui assessment');
        }
      } else {
        throw Exception('Failed to update assessment');
      }
    } catch (e) {
      debugPrint('Error updating assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
