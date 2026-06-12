import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/member.dart';

class TrainerManagement extends StatefulWidget {
  const TrainerManagement({super.key});

  @override
  State<TrainerManagement> createState() => _TrainerManagementState();
}

class _TrainerManagementState extends State<TrainerManagement> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _trainers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers({String query = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiClient.getTrainers(
        query: query.isNotEmpty ? 'search=$query' : '',
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _trainers = dynamicList;
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load trainers');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load trainers. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _fetchTrainers(query: query);
  }

  Future<void> _deleteTrainer(String trainerId, String trainerName) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: const Text('Delete Trainer Profile?', style: TextStyle(color: AppColors.white)),
        content: Text(
          'Are you sure you want to remove $trainerName? This will also deactivate their linked trainer account.',
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      try {
        final res = await _apiClient.deleteTrainer(trainerId);
        if (res.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Trainer $trainerName deleted successfully.')),
            );
          }
          _fetchTrainers();
        } else {
          final body = jsonDecode(res.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(body['message'] ?? 'Failed to delete trainer'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTrainerFormSheet({Map<String, dynamic>? trainer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _TrainerFormSheet(
          trainer: trainer,
          onSaved: () {
            context.pop();
            _fetchTrainers();
          },
        );
      },
    );
  }

  void _showManageSheet(Map<String, dynamic> trainer) {
    final String trainerId = trainer['id'];
    final String fullName = trainer['user']?['full_name'] ?? 'Staff Member';
    final String statusStr = trainer['status'] ?? 'ACTIVE';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  fullName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primaryFixed),
                title: const Text('Edit Profile & Status', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.pop();
                  _showTrainerFormSheet(trainer: trainer);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blueAccent),
                title: const Text('Assign Member', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.pop();
                  _showAssignMemberSheet(trainer);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.orangeAccent),
                title: const Text('View Assigned Clients', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.pop();
                  _showTrainerClientsDialog(trainerId, fullName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Remove Staff', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  context.pop();
                  _deleteTrainer(trainerId, fullName);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAssignMemberSheet(Map<String, dynamic> trainer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _AssignMemberSheet(
          trainer: trainer,
          onAssigned: () {
            context.pop();
            _fetchTrainers();
          },
        );
      },
    );
  }

  void _showTrainerClientsDialog(String trainerId, String trainerName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return _TrainerClientsListWidget(
              trainerId: trainerId,
              trainerName: trainerName,
              scrollController: scrollController,
            );
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
          'TRAINER STAFF',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.primaryFixed),
            onPressed: () => _showTrainerFormSheet(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name, spec, or emp id...',
                  hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryFixed,
                onRefresh: () => _fetchTrainers(query: _searchController.text),
                child: _isLoading && _trainers.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                    : _errorMessage.isNotEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                              Center(
                                child: Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : _trainers.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                  const Center(
                                    child: Text(
                                      'No trainers registered yet.\nClick "+" to add one!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: _trainers.length,
                                itemBuilder: (context, index) {
                                  final trainer = _trainers[index];
                                  final String name = trainer['user']?['full_name'] ?? 'No Name';
                                  final String spec = trainer['specialization'] ?? 'General Trainer';
                                  final String statusStr = trainer['status'] ?? 'ACTIVE';
                                  final String empId = trainer['employee_id'] ?? '';
                                  final int experience = trainer['experience_years'] ?? 0;

                                  Color statusColor = Colors.green;
                                  if (statusStr == 'INACTIVE') statusColor = Colors.grey;
                                  if (statusStr == 'SUSPENDED') statusColor = Colors.red;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF201F1F),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: statusStr == 'ACTIVE' ? Colors.white05 : Colors.red.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            const CircleAvatar(
                                              radius: 30,
                                              backgroundColor: AppColors.primaryFixed,
                                              child: Icon(Icons.fitness_center, color: AppColors.background),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: statusColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: const Color(0xFF201F1F), width: 2),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$spec • $experience Yrs Exp',
                                                style: const TextStyle(
                                                  color: AppColors.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ID: $empId',
                                                style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontFamily: 'JetBrains Mono',
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        OutlinedButton(
                                          onPressed: () => _showManageSheet(trainer),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primaryFixed,
                                            side: const BorderSide(color: AppColors.primaryFixed),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Manage'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainerFormSheet extends StatefulWidget {
  final Map<String, dynamic>? trainer;
  final VoidCallback onSaved;

  const _TrainerFormSheet({this.trainer, required this.onSaved});

  @override
  State<_TrainerFormSheet> createState() => _TrainerFormSheetState();
}

class _TrainerFormSheetState extends State<_TrainerFormSheet> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _empIdController;
  late TextEditingController _specController;
  late TextEditingController _certController;
  late TextEditingController _expController;
  late TextEditingController _salaryController;
  late TextEditingController _bioController;

  String _status = 'ACTIVE';
  bool _isSaving = false;

  bool get isEdit => widget.trainer != null;

  @override
  void initState() {
    super.initState();
    final t = widget.trainer;
    final u = t?['user'];

    _emailController = TextEditingController(text: u?['email'] ?? '');
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController(text: u?['full_name'] ?? '');
    _phoneController = TextEditingController(text: u?['phone_number'] ?? '');
    _empIdController = TextEditingController(text: t?['employee_id'] ?? '');
    _specController = TextEditingController(text: t?['specialization'] ?? '');
    _certController = TextEditingController(text: t?['certifications'] ?? '');
    _expController = TextEditingController(text: t?['experience_years']?.toString() ?? '0');
    _salaryController = TextEditingController(text: t?['salary']?.toString() ?? '0.00');
    _bioController = TextEditingController(text: t?['bio'] ?? '');
    _status = t?['status'] ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _empIdController.dispose();
    _specController.dispose();
    _certController.dispose();
    _expController.dispose();
    _salaryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveTrainer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      'full_name': _fullNameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'specialization': _specController.text.trim(),
      'experience_years': int.tryParse(_expController.text) ?? 0,
      'certifications': _certController.text.trim(),
      'salary': double.tryParse(_salaryController.text) ?? 0.0,
      'bio': _bioController.text.trim(),
      'status': _status,
    };

    try {
      if (isEdit) {
        final res = await _apiClient.updateTrainer(widget.trainer!['id'], payload);
        if (res.statusCode == 200) {
          widget.onSaved();
        } else {
          final body = jsonDecode(res.body);
          _showError(body['message'] ?? 'Failed to update trainer');
        }
      } else {
        payload['email'] = _emailController.text.trim();
        payload['password'] = _passwordController.text.isNotEmpty
            ? _passwordController.text
            : 'Trainer@Pass123';
        payload['employee_id'] = _empIdController.text.trim();

        final res = await _apiClient.createTrainer(payload);
        if (res.statusCode == 201) {
          widget.onSaved();
        } else {
          final body = jsonDecode(res.body);
          String errorMsg = 'Failed to create trainer';
          if (body['errors'] != null) {
            if (body['errors'] is Map) {
              errorMsg = body['errors'].entries.map((e) => "${e.key}: ${e.value}").join("\n");
            } else if (body['errors'] is List) {
              errorMsg = body['errors'].map((e) => e['message'] ?? '').join("\n");
            }
          } else if (body['message'] != null) {
            errorMsg = body['message'];
          }
          _showError(errorMsg);
        }
      }
    } catch (e) {
      _showError('Network/Server error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'EDIT TRAINER' : 'REGISTER TRAINER',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (!isEdit) ...[
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Trainer Email',
                    labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Email required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Temp Password (Default: Trainer@Pass123)',
                    labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _empIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Employee ID required' : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Full Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Phone required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Specialization (e.g. Bodybuilding, Yoga)',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _certController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Certifications',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Experience (Years)',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Salary ($)',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Bio / Notes',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF201F1F),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                  DropdownMenuItem(value: 'SUSPENDED', child: Text('SUSPENDED')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveTrainer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: AppColors.background)
                    : Text(
                        isEdit ? 'SAVE CHANGES' : 'REGISTER TRAINER',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignMemberSheet extends StatefulWidget {
  final Map<String, dynamic> trainer;
  final VoidCallback onAssigned;

  const _AssignMemberSheet({required this.trainer, required this.onAssigned});

  @override
  State<_AssignMemberSheet> createState() => _AssignMemberSheetState();
}

class _AssignMemberSheetState extends State<_AssignMemberSheet> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();

  List<Member> _members = [];
  Member? _selectedMember;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadGymMembers();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadGymMembers() async {
    try {
      final res = await _apiClient.getMembers(query: 'status=ACTIVE');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _members = dynamicList.map((m) => Member.fromJson(m)).toList();
          });
        }
      }
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final int memberIdInt = int.parse(_selectedMember!.id);
      final res = await _apiClient.createTrainerAssignment({
        'trainer_id': widget.trainer['id'],
        'member_id': memberIdInt,
        'notes': _notesController.text.trim(),
      });

      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully assigned ${widget.trainer['user']['full_name']} to ${_selectedMember!.fullName}',
              ),
            ),
          );
        }
        widget.onAssigned();
      } else {
        final body = jsonDecode(res.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Failed to assign trainer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning member: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String trainerName = widget.trainer['user']?['full_name'] ?? 'Trainer';

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ASSIGN CLIENT TO $trainerName',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.primaryFixed),
                ),
              )
            else if (_members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'No active members found in gym to assign.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              )
            else ...[
              DropdownButtonFormField<Member>(
                value: _selectedMember,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF201F1F),
                decoration: const InputDecoration(
                  labelText: 'Select Active Member',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
                items: _members.map((m) {
                  return DropdownMenuItem<Member>(
                    value: m,
                    child: Text(m.fullName),
                  );
                }).toList(),
                onChanged: (m) {
                  setState(() => _selectedMember = m);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Assignment Notes (e.g. schedules, goals)',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: AppColors.background)
                    : const Text(
                        'SUBMIT ASSIGNMENT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrainerClientsListWidget extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final ScrollController scrollController;

  const _TrainerClientsListWidget({
    required this.trainerId,
    required this.trainerName,
    required this.scrollController,
  });

  @override
  State<_TrainerClientsListWidget> createState() => _TrainerClientsListWidgetState();
}

class _TrainerClientsListWidgetState extends State<_TrainerClientsListWidget> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _clients = [];
  bool _isLoading = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final res = await _apiClient.getTrainerMembers(widget.trainerId);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _clients = dynamicList;
          });
        } else {
          setState(() => _errorMsg = body['message'] ?? 'Failed to load clients');
        }
      } else {
        setState(() => _errorMsg = 'Failed to load clients. Code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error loading clients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ACTIVE CLIENTS - ${widget.trainerName.toUpperCase()}',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                : _errorMsg.isNotEmpty
                    ? Center(child: Text(_errorMsg, style: const TextStyle(color: Colors.red)))
                    : _clients.isEmpty
                        ? const Center(
                            child: Text(
                              'No clients actively assigned to this trainer.',
                              style: TextStyle(color: AppColors.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            controller: widget.scrollController,
                            itemCount: _clients.length,
                            itemBuilder: (context, index) {
                              final c = _clients[index];
                              final String name = c['full_name'] ?? 'Unnamed Member';
                              final double attPct = (c['attendance_percentage'] ?? 0.0).toDouble();
                              final String plan = c['plan_name'] ?? 'No Active Plan';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222121),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white12,
                                      child: Icon(Icons.person, color: AppColors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            plan,
                                            style: const TextStyle(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${attPct.toStringAsFixed(0)}% Att',
                                          style: const TextStyle(
                                            color: AppColors.primaryFixed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Attendance',
                                          style: TextStyle(color: Colors.white30, fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
