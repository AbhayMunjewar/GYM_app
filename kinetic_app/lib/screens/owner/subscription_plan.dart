import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/membership_plan.dart';

class SubscriptionPlan extends StatefulWidget {
  const SubscriptionPlan({super.key});

  @override
  State<SubscriptionPlan> createState() => _SubscriptionPlanState();
}

class _SubscriptionPlanState extends State<SubscriptionPlan> {
  final ApiClient _apiClient = ApiClient();
  List<MembershipPlan> _plans = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiClient.getMembershipPlans();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _plans = dynamicList.map((p) => MembershipPlan.fromJson(p)).toList();
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load plans');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load plans. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePlanStatus(MembershipPlan plan, bool isActive) async {
    try {
      final res = await _apiClient.updateMembershipPlan(plan.id, {'is_active': isActive});
      if (res.statusCode == 200) {
        _fetchPlans();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showPlanFormSheet({MembershipPlan? existingPlan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _PlanFormSheet(
          plan: existingPlan,
          onSaved: () {
            context.pop();
            _fetchPlans();
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('PLAN MANAGEMENT', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
              child: _isLoading && _plans.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : _plans.isEmpty
                      ? const Center(child: Text('No plans found.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPlanCard(plan),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPlanFormSheet(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Plan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryFixed,
                    side: const BorderSide(color: AppColors.primaryFixed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(MembershipPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: plan.isActive ? AppColors.primaryFixed : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(plan.planName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.onSurfaceVariant, size: 20),
                    onPressed: () => _showPlanFormSheet(existingPlan: plan),
                  ),
                  Switch(
                    value: plan.isActive, 
                    onChanged: (v) => _togglePlanStatus(plan, v), 
                    activeColor: AppColors.primaryFixed,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('\$${plan.price} / ${plan.durationDays} days', style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (plan.description != null && plan.description!.isNotEmpty)
            Text(plan.description!, style: const TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _PlanFormSheet extends StatefulWidget {
  final MembershipPlan? plan;
  final VoidCallback onSaved;

  const _PlanFormSheet({this.plan, required this.onSaved});

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.plan?.planName);
    _descCtrl = TextEditingController(text: widget.plan?.description);
    _durationCtrl = TextEditingController(text: widget.plan?.durationDays.toString());
    _priceCtrl = TextEditingController(text: widget.plan?.price);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'plan_name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'duration_days': int.parse(_durationCtrl.text.trim()),
      'price': double.parse(_priceCtrl.text.trim()),
      'is_active': widget.plan?.isActive ?? true,
    };

    try {
      final res = widget.plan == null
          ? await _apiClient.createMembershipPlan(data)
          : await _apiClient.updateMembershipPlan(widget.plan!.id, data);

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
              Text(widget.plan == null ? 'NEW PLAN' : 'EDIT PLAN', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildField(_nameCtrl, 'Plan Name', Icons.card_membership),
              _buildField(_descCtrl, 'Description', Icons.description, maxLines: 2, requiredField: false),
              Row(
                children: [
                  Expanded(child: _buildField(_durationCtrl, 'Duration (Days)', Icons.timer, type: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_priceCtrl, 'Price', Icons.attach_money, type: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
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
                    : const Text('SAVE PLAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
