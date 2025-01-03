import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';

class AddAssessmentPage extends StatefulWidget {
  const AddAssessmentPage({super.key});

  @override
  State<AddAssessmentPage> createState() => _AddAssessmentPageState();
}

class _AddAssessmentPageState extends State<AddAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  
  final TextEditingController _yearAcademicController = TextEditingController();
  final TextEditingController _yearAssessmentController = TextEditingController();
  final TextEditingController _regIdStudentController = TextEditingController();
  final TextEditingController _idAspectSubController = TextEditingController();
  final TextEditingController _idCoachController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();
  final TextEditingController _idAspectController = TextEditingController();
  final TextEditingController _idPointRateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _yearAcademicController.dispose();
    _yearAssessmentController.dispose();
    _regIdStudentController.dispose();
    _idAspectSubController.dispose();
    _idCoachController.dispose();
    _pointController.dispose();
    _ketController.dispose();
    _idAspectController.dispose();
    _idPointRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020), // Set to a past year to avoid the assertion error
      lastDate: DateTime(2025, 12, 31), // Set to end of 2025
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAssessment() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      
      final response = await http.post(
        Uri.parse('${Config.baseUrl}assessments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'year_academic': _yearAcademicController.text,
          'year_assessment': _yearAssessmentController.text,
          'reg_id_student': _regIdStudentController.text,
          'id_aspect_sub': _idAspectSubController.text,
          'id_coach': _idCoachController.text,
          'point': int.parse(_pointController.text),
          'ket': _ketController.text,
          'date_assessment': _selectedDate?.toIso8601String(),
          'id_aspect': _idAspectController.text,
          'id_point_rate': _idPointRateController.text
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment berhasil dibuat')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create assessment');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Add New Assessment',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _yearAcademicController,
                labelText: 'Academic Year',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter academic year' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _yearAssessmentController,
                labelText: 'Assessment Year',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter assessment year' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _regIdStudentController,
                labelText: 'Student ID',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter student ID' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _idAspectSubController,
                labelText: 'Aspect Sub ID',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter aspect sub ID' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _idCoachController,
                labelText: 'Coach ID',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter coach ID' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _pointController,
                labelText: 'Point',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter point' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ketController,
                labelText: 'Description',
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _idAspectController,
                labelText: 'Aspect ID',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter aspect ID' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _idPointRateController,
                labelText: 'Point Rate ID',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter point rate ID' : null,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    _selectedDate == null 
                      ? 'Select Assessment Date'
                      : 'Assessment Date: ${_selectedDate.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedDate == null 
                        ? Colors.white.withOpacity(0.7)
                        : Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                    ),
                    borderRadius: BorderRadius.circular(8),
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
                      if (_formKey.currentState!.validate() && _selectedDate != null) {
                        _saveAssessment();
                      } else if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select assessment date')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    child: const Text(
                      'Save Assessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }
}
