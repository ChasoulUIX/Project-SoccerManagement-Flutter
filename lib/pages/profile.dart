import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  final baseUrl = '${Config.baseUrl}management/';
  bool _isLoading = false;
  String? _error;
  final Map<String, dynamic> _profile = {
    'name': '',
    'gender': '',
    'date_birth': '',
    'email': '',
    'nohp': '',
    'id_departement': '',
    'status': '',
  };
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String _selectedGender = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No auth token found');

      final decodedToken = json.decode(
        ascii.decode(
          base64.decode(base64.normalize(token.split('.')[1])),
        ),
      );

      final idManagement = decodedToken['id_management'];
      if (idManagement == null) throw Exception('No id_management in token');

      final response = await http.get(
        Uri.parse('$baseUrl$idManagement'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            final profileData = data['data'];
            _profile.update('name', (_) => profileData['name'] ?? '');
            _profile.update('gender', (_) => profileData['gender'] ?? '');
            _profile.update('date_birth',
                (_) => profileData['date_birth']?.substring(0, 10) ?? '');
            _profile.update('email', (_) => profileData['email'] ?? '');
            _profile.update('nohp', (_) => profileData['nohp'] ?? '');
            _profile.update(
                'id_departement', (_) => profileData['name_departement'] ?? '');
            _profile.update('status', (_) => profileData['status'] ?? '');
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load profile');
        }
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildProfileInfo(),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _profile['name'] ?? 'No Name',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Department: ${_profile['id_departement'] ?? 'Not Set'}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoItem(
              Icons.person, 'Gender', _profile['gender'] ?? 'Not Set'),
          const Divider(color: Colors.white12),
          _buildInfoItem(Icons.calendar_today, 'Date of Birth',
              _profile['date_birth'] ?? 'Not Set'),
          const Divider(color: Colors.white12),
          _buildInfoItem(Icons.email, 'Email', _profile['email'] ?? 'Not Set'),
          const Divider(color: Colors.white12),
          _buildInfoItem(Icons.phone, 'Phone', _profile['nohp'] ?? 'Not Set'),
          const Divider(color: Colors.white12),
          _buildInfoItem(Icons.check_circle, 'Status',
              _profile['status']?.toString() ?? 'Not Set'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildButton('Edit Profile', Icons.edit, Colors.green),
        const SizedBox(height: 8),
        _buildButton('Change Password', Icons.lock, Colors.orange),
        const SizedBox(height: 8),
        _buildButton('Logout', Icons.exit_to_app, Colors.red),
      ],
    );
  }

  Widget _buildButton(String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (label == 'Edit Profile') {
              _showEditProfileModal();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileModal() {
    _nameController.text = _profile['name'] ?? '';
    _emailController.text = _profile['email'] ?? '';
    _phoneController.text = _profile['nohp'] ?? '';
    _birthDateController.text = _profile['date_birth'] ?? '';
    _selectedGender = _profile['gender'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Name', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone', Icons.phone),
              const SizedBox(height: 12),
              _buildTextField(
                  _birthDateController, 'Birth Date', Icons.calendar_today),
              const SizedBox(height: 12),
              _buildGenderDropdown(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleUpdateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender.isNotEmpty && ['L', 'P'].contains(_selectedGender)
          ? _selectedGender
          : null,
      items: ['L', 'P']
          .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedGender = value ?? '');
      },
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon:
            Icon(Icons.person_outline, color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
    );
  }

  Future<void> _handleUpdateProfile() async {
    // TODO: Implement the API call to update the profile
    // For now, just close the modal
    Navigator.pop(context);
  }
}
