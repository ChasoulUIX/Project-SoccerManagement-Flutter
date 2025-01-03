import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import 'add/addstudent.dart';

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _students = [];
  String _searchQuery = '';
  final String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}student'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _students = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load students');
        }
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent(String id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}student/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Student berhasil dihapus')),
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to delete student');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateStudent(String id, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}student/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        await _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? 'Student berhasil diupdate')),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update student');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showEditModal(Map<String, dynamic> student) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: student['name']);
    final emailController = TextEditingController(text: student['email']);
    final phoneController = TextEditingController(text: student['nohp']);
    final photoController = TextEditingController(text: student['photo']);
    DateTime? selectedDateBirth = student['date_birth'] != null
        ? DateTime.parse(student['date_birth'])
        : null;
    DateTime? selectedRegistrationDate = student['registration_date'] != null
        ? DateTime.parse(student['registration_date'])
        : null;
    String? selectedGender = student['gender'];
    bool status = student['status'] == 1 || student['status'] == true;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Edit Student',
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
                          labelText: 'Full Name',
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
                      TextFormField(
                        controller: emailController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required field';
                          if (!value!.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDateBirth ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
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
                            setState(() => selectedDateBirth = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          child: Text(
                            selectedDateBirth != null
                                ? '${selectedDateBirth!.day}/${selectedDateBirth!.month}/${selectedDateBirth!.year}'
                                : 'Select date',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'L', child: Text('L')),
                          DropdownMenuItem(value: 'P', child: Text('P')),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedGender = value),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Status',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13)),
                        value: status,
                        onChanged: (value) => setState(() => status = value),
                        activeColor: Colors.green,
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
                      Navigator.pop(context, {
                        'name': nameController.text,
                        'email': emailController.text,
                        'date_birth': selectedDateBirth?.toIso8601String(),
                        'gender': selectedGender,
                        'status': status,
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
      await _updateStudent(student['id_student'].toString(), result);
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 12),
                              _buildQuickStats(),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildStudentCard(_students[index]),
                            childCount: _students.length,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
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
                hintText: 'Search students...',
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
              onChanged: (value) => setState(() => _searchQuery = value),
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
                MaterialPageRoute(builder: (context) => const AddStudentPage()),
              ).then((_) => _loadStudents());
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
    );
  }

  Widget _buildQuickStats() {
    final totalStudents = _students.length;
    final activeStudents = _students.where((s) => s['status'] == true).length;
    final inactiveStudents = totalStudents - activeStudents;

    return Row(
      children: [
        _buildStatItem('Total', totalStudents.toString(), Colors.blue),
        _buildStatItem('Active', activeStudents.toString(), Colors.green),
        _buildStatItem('Inactive', inactiveStudents.toString(), Colors.red),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
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
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                NetworkImage(student['photo'] ?? 'https://i.pravatar.cc/150'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student['email'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        (student['status'] == true ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    student['status'] == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color:
                          student['status'] == true ? Colors.green : Colors.red,
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
                await _showEditModal(student);
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Yakin ingin menghapus student ini?'),
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
                  await _deleteStudent(student['id_student'].toString());
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
