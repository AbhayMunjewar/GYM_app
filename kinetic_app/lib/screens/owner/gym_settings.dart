import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/gym.dart';

class GymSettings extends StatefulWidget {
  const GymSettings({super.key});

  @override
  State<GymSettings> createState() => _GymSettingsState();
}

class _GymSettingsState extends State<GymSettings> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Gym? _currentGym;
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGym();
  }

  Future<void> _fetchGym() async {
    try {
      final response = await _apiClient.getGyms();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'].isNotEmpty) {
          // Assume owner manages the first returned gym for now
          _currentGym = Gym.fromJson(data['data'][0]);
          _populateForm(_currentGym!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching gym: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateForm(Gym gym) {
    _nameController.text = gym.gymName;
    _addressController.text = gym.address;
    _cityController.text = gym.city;
    _stateController.text = gym.state;
    _pincodeController.text = gym.pincode;
    _contactController.text = gym.contactNumber;
    _emailController.text = gym.email;
    _descController.text = gym.description ?? '';
  }

  Future<void> _saveGym() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final gymData = {
      'gym_name': _nameController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'contact_number': _contactController.text,
      'email': _emailController.text,
      'description': _descController.text,
    };

    try {
      final response = _currentGym == null 
        ? await _apiClient.createGym(gymData)
        : await _apiClient.updateGym(_currentGym!.id, gymData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gym details saved successfully!', style: TextStyle(color: AppColors.background)), backgroundColor: AppColors.primaryFixed),
        );
        _fetchGym(); // Refresh
      } else {
        if (!mounted) return;
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message'] ?? 'Failed to save'}', style: const TextStyle(color: AppColors.white)), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e', style: const TextStyle(color: AppColors.white)), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('SETTINGS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
        : SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader('Gym Profile'),
                  _buildTextField(_nameController, 'Gym Name', Icons.fitness_center),
                  _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                  _buildTextField(_contactController, 'Contact Number', Icons.phone, keyboardType: TextInputType.phone),
                  _buildTextField(_addressController, 'Address', Icons.location_on),
                  _buildTextField(_cityController, 'City', Icons.location_city),
                  _buildTextField(_stateController, 'State', Icons.map),
                  _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop),
                  _buildTextField(_descController, 'Description', Icons.description, maxLines: 3, requiredField: false),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('Billing & Payments'),
                  ListTile(
                    tileColor: const Color(0xFF201F1F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.payment, color: AppColors.primaryFixed),
                    title: const Text('Configure UPI & QR Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Set your Gym\'s UPI ID and QR code for member payments', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    onTap: () => context.push('/owner/billing/settings'),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveGym,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryFixed,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                      : Text(_currentGym == null ? 'CREATE GYM' : 'UPDATE GYM', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),

                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => context.go('/auth/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB4AB), 
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('LOG OUT (OWNER)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool requiredField = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
          filled: true,
          fillColor: const Color(0xFF201F1F),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryFixed)),
        ),
        validator: requiredField ? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        } : null,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
