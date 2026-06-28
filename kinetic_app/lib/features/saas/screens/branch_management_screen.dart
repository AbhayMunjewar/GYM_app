import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_client.dart';

class SaasBranchManagementScreen extends StatefulWidget {
  const SaasBranchManagementScreen({super.key});

  @override
  State<SaasBranchManagementScreen> createState() => _SaasBranchManagementScreenState();
}

class _SaasBranchManagementScreenState extends State<SaasBranchManagementScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMessage = '';

  List<dynamic> _branches = [];

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _apiClient.getBranches();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _branches = body['data'] ?? [];
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load branches');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load branches. Code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBranch(String id) async {
    try {
      final res = await _apiClient.deleteBranch(id);
      if (res.statusCode == 200) {
        _fetchBranches();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete branch'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showBranchFormSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _BranchFormSheet(
          onSaved: () {
            context.pop();
            _fetchBranches();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'BRANCH MANAGEMENT',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : _branches.isEmpty
                      ? const Center(child: Text('No active branches found.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _branches.length,
                          itemBuilder: (context, index) {
                            final branch = _branches[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildBranchCard(branch),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showBranchFormSheet,
                  icon: const Icon(Icons.add, color: AppColors.background),
                  label: const Text('ADD NEW BRANCH', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    final name = branch['branch_name'] ?? '';
    final id = branch['id'];
    final city = branch['city'] ?? '';
    final state = branch['state'] ?? '';
    final contact = branch['contact_number'] ?? '';
    final email = branch['email'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name.toUpperCase(),
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                onPressed: () => _deleteBranch(id),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text('$city, $state', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Call: $contact', style: const TextStyle(color: Colors.white30, fontSize: 12)),
          Text('Email: $email', style: const TextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BranchFormSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _BranchFormSheet({required this.onSaved});

  @override
  State<_BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends State<_BranchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  bool _isSaving = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addrCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'branch_name': _nameCtrl.text.trim(),
      'address': _addrCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'pincode': _pinCtrl.text.trim(),
      'contact_number': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
    };

    try {
      final res = await _apiClient.createBranch(data);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        widget.onSaved();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to save branch. Limit exceeded?'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('NEW GYM BRANCH', style: TextStyle(color: AppColors.primaryFixed, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildField(_nameCtrl, 'Branch Name', Icons.store),
              _buildField(_addrCtrl, 'Address', Icons.location_on),
              Row(
                children: [
                  Expanded(child: _buildField(_cityCtrl, 'City', Icons.location_city)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_stateCtrl, 'State', Icons.map)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildField(_pinCtrl, 'Pincode', Icons.pin_drop, type: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_phoneCtrl, 'Contact Number', Icons.phone, type: TextInputType.phone)),
                ],
              ),
              _buildField(_emailCtrl, 'Email Address', Icons.email, type: TextInputType.emailAddress),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                    : const Text('SAVE BRANCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
          filled: true,
          fillColor: const Color(0xFF201F1F),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (val) => val!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
