import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/member.dart';
import '../../models/membership_plan.dart';

class MembersManagement extends StatefulWidget {
  const MembersManagement({super.key});

  @override
  State<MembersManagement> createState() => _MembersManagementState();
}

class _MembersManagementState extends State<MembersManagement> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  
  List<Member> _members = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers({String query = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiClient.getMembers(query: query.isNotEmpty ? 'search=$query' : '');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _members = dynamicList.map((m) => Member.fromJson(m)).toList();
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load members');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load members. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    // Simple debounce can be added here if needed.
    _fetchMembers(query: query);
  }

  void _showMemberFormSheet({Member? existingMember}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _MemberFormSheet(
          member: existingMember,
          onSaved: () {
            context.pop();
            _fetchMembers();
          },
        );
      },
    );
  }

  void _showAssignPlanSheet(Member member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _AssignPlanSheet(
          member: member,
          onAssigned: () {
            context.pop();
            _fetchMembers();
          },
        );
      },
    );
  }

  Future<void> _deleteMember(Member member) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: const Text('Delete Member?', style: TextStyle(color: AppColors.white)),
        content: Text('Are you sure you want to remove ${member.fullName}?', style: const TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant))),
          TextButton(onPressed: () => context.pop(true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      try {
        final res = await _apiClient.deleteMember(member.id);
        if (res.statusCode == 200) {
          _fetchMembers();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete member'), backgroundColor: Colors.red));
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _manualCheckIn(Member member) async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.checkInAttendance({'member_id': member.id});
      if (res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.fullName} checked in', style: const TextStyle(color: Colors.white))));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${res.body}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _manualCheckOut(Member member) async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.checkOutAttendance({'member_id': member.id});
      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.fullName} checked out', style: const TextStyle(color: Colors.white))));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${res.body}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
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
        title: const Text('MEMBERS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppColors.primaryFixed), onPressed: () => _showMemberFormSheet()),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: _isLoading && _members.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : _members.isEmpty
                      ? const Center(child: Text('No members found.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryFixed.withValues(alpha: 0.2),
                                    child: const Icon(Icons.person, color: AppColors.primaryFixed),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(member.fullName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                          Text('${member.email} • ${member.status}${member.activePlanName != null ? ' • ${member.activePlanName}' : ''}', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 12)),
                                        ],
                                      ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                                    color: const Color(0xFF201F1F),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showMemberFormSheet(existingMember: member);
                                      } else if (value == 'delete') {
                                        _deleteMember(member);
                                      } else if (value == 'check_in') {
                                        _manualCheckIn(member);
                                      } else if (value == 'check_out') {
                                        _manualCheckOut(member);
                                      } else if (value == 'assign_plan') {
                                        _showAssignPlanSheet(member);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'assign_plan', child: Text('Assign Plan', style: TextStyle(color: Colors.blueAccent))),
                                      const PopupMenuItem(value: 'check_in', child: Text('Check In', style: TextStyle(color: AppColors.primaryFixed))),
                                      const PopupMenuItem(value: 'check_out', child: Text('Check Out', style: TextStyle(color: Colors.orange))),
                                      const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.white))),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
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
      ),
    );
  }
}

class _MemberFormSheet extends StatefulWidget {
  final Member? member;
  final VoidCallback onSaved;

  const _MemberFormSheet({this.member, required this.onSaved});

  @override
  State<_MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<_MemberFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _notesCtrl;

  String _status = 'ACTIVE';
  String? _gender;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.member?.fullName);
    _emailCtrl = TextEditingController(text: widget.member?.email);
    _phoneCtrl = TextEditingController(text: widget.member?.phoneNumber);
    _contactCtrl = TextEditingController(text: widget.member?.emergencyContact);
    _addressCtrl = TextEditingController(text: widget.member?.address);
    _heightCtrl = TextEditingController(text: widget.member?.heightCm?.toString());
    _weightCtrl = TextEditingController(text: widget.member?.weightKg?.toString());
    _notesCtrl = TextEditingController(text: widget.member?.notes);

    if (widget.member != null) {
      _status = widget.member!.status;
      _gender = widget.member!.gender;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'full_name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'emergency_contact': _contactCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'height_cm': _heightCtrl.text.isNotEmpty ? double.parse(_heightCtrl.text) : null,
      'weight_kg': _weightCtrl.text.isNotEmpty ? double.parse(_weightCtrl.text) : null,
      'notes': _notesCtrl.text.trim(),
      'status': _status,
      if (_gender != null) 'gender': _gender,
    };

    try {
      final res = widget.member == null
          ? await _apiClient.createMember(data)
          : await _apiClient.updateMember(widget.member!.id, data);

      if (res.statusCode == 200 || res.statusCode == 201) {
        widget.onSaved();
      } else {
        if (!mounted) return;
        final errData = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errData['message'] ?? 'Save failed'), backgroundColor: Colors.red));
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
              Text(widget.member == null ? 'NEW MEMBER' : 'EDIT MEMBER', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildField(_nameCtrl, 'Full Name', Icons.person),
              _buildField(_emailCtrl, 'Email', Icons.email, type: TextInputType.emailAddress),
              _buildField(_phoneCtrl, 'Phone Number', Icons.phone, type: TextInputType.phone),
              _buildField(_contactCtrl, 'Emergency Contact', Icons.contact_phone, requiredField: false),
              
              Row(
                children: [
                  Expanded(child: _buildField(_heightCtrl, 'Height (cm)', Icons.height, type: const TextInputType.numberWithOptions(decimal: true), requiredField: false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_weightCtrl, 'Weight (kg)', Icons.monitor_weight, type: const TextInputType.numberWithOptions(decimal: true), requiredField: false)),
                ],
              ),
              
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: const Color(0xFF201F1F),
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                  DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended')),
                ],
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),

              _buildField(_addressCtrl, 'Address', Icons.location_on, requiredField: false),
              _buildField(_notesCtrl, 'Notes', Icons.note, maxLines: 2, requiredField: false),

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
                    : const Text('SAVE MEMBER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1, bool requiredField = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
          filled: true,
          fillColor: const Color(0xFF201F1F),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: requiredField ? (val) => val!.isEmpty ? 'Required' : null : null,
      ),
    );
  }
}

class _AssignPlanSheet extends StatefulWidget {
  final Member member;
  final VoidCallback onAssigned;

  const _AssignPlanSheet({required this.member, required this.onAssigned});

  @override
  State<_AssignPlanSheet> createState() => _AssignPlanSheetState();
}

class _AssignPlanSheetState extends State<_AssignPlanSheet> {
  final ApiClient _apiClient = ApiClient();
  List<MembershipPlan> _plans = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedPlanId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await _apiClient.getMembershipPlans(query: 'is_active=true');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _plans = dynamicList.map((p) => MembershipPlan.fromJson(p)).toList();
            if (_plans.isNotEmpty) {
              _selectedPlanId = _plans.first.id;
            }
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load plans');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load plans');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignPlan() async {
    if (_selectedPlanId == null) return;
    setState(() => _isSaving = true);

    try {
      final res = await _apiClient.assignMembership({
        'member_id': widget.member.id,
        'membership_plan_id': _selectedPlanId,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan assigned successfully!', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primaryFixed));
        widget.onAssigned();
      } else {
        if (!mounted) return;
        final errData = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errData['message'] ?? 'Assignment failed'), backgroundColor: Colors.red));
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ASSIGN PLAN TO ${widget.member.fullName.toUpperCase()}', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
          else if (_errorMessage.isNotEmpty)
            Text(_errorMessage, style: const TextStyle(color: Colors.red))
          else if (_plans.isEmpty)
            const Text('No active plans available. Please create one first.', style: TextStyle(color: AppColors.onSurfaceVariant))
          else ...[
            DropdownButtonFormField<String>(
              value: _selectedPlanId,
              dropdownColor: const Color(0xFF201F1F),
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'Select Membership Plan',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: const Color(0xFF201F1F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _plans.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.planName} (\$${p.price} / ${p.durationDays}d)'))).toList(),
              onChanged: (val) => setState(() => _selectedPlanId = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving || _selectedPlanId == null ? null : _assignPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                  : const Text('ASSIGN PLAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ],
      ),
    );
  }
}
