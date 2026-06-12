import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController(text: '10');

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<dynamic> _trainers = [];
  dynamic _selectedTrainer;
  String? _gymId;
  bool _isLoadingTrainers = true;
  bool _isSaving = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchGymAndTrainers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _fetchGymAndTrainers() async {
    try {
      // 1. Fetch Gym
      final gymRes = await _apiClient.getGyms();
      if (gymRes.statusCode == 200) {
        final body = jsonDecode(gymRes.body);
        if (body['success'] == true && body['data'] != null) {
          final list = body['data'] as List;
          if (list.isNotEmpty) {
            _gymId = list[0]['id']?.toString();
          }
        }
      }

      if (_gymId == null) {
        setState(() {
          _errorMsg = 'Gym profile not found. Cannot create session.';
          _isLoadingTrainers = false;
        });
        return;
      }

      // 2. Fetch Trainers
      final trainerRes = await _apiClient.getTrainers(query: 'status=ACTIVE');
      if (trainerRes.statusCode == 200) {
        final body = jsonDecode(trainerRes.body);
        if (body['success'] == true) {
          setState(() {
            _trainers = body['data']['results'] ?? body['data'];
          });
        }
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error loading trainers: $e');
    } finally {
      setState(() => _isLoadingTrainers = false);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryFixed,
              onPrimary: AppColors.background,
              surface: Color(0xFF201F1F),
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showSnackBar('Please select a date.');
      return;
    }
    if (_startTime == null) {
      _showSnackBar('Please select a start time.');
      return;
    }
    if (_endTime == null) {
      _showSnackBar('Please select an end time.');
      return;
    }
    if (_selectedTrainer == null) {
      _showSnackBar('Please select a trainer.');
      return;
    }

    // Client-side time validation
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      _showSnackBar('End time must be strictly after start time.');
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      'gym': _gymId,
      'trainer': _selectedTrainer['id'],
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'session_date': _formatDate(_selectedDate!),
      'start_time': _formatTime(_startTime!),
      'end_time': _formatTime(_endTime!),
      'max_capacity': int.tryParse(_capacityController.text) ?? 10
    };

    try {
      final res = await _apiClient.createSession(payload);
      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session scheduled successfully!')),
          );
          context.pop(true); // Pop and signal refresh
        }
      } else {
        final body = jsonDecode(res.body);
        _showSnackBar(body['message'] ?? 'Failed to schedule session.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
          'SCHEDULE SESSION',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoadingTrainers
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : _errorMsg.isNotEmpty
                ? Center(child: Text(_errorMsg, style: const TextStyle(color: Colors.red)))
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              style: const TextStyle(color: Colors.white),
                              maxLength: 100,
                              decoration: const InputDecoration(
                                labelText: 'Session Title',
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Title required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<dynamic>(
                              value: _selectedTrainer,
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: const Color(0xFF201F1F),
                              decoration: const InputDecoration(
                                labelText: 'Select Trainer',
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                              ),
                              items: _trainers.map((t) {
                                final String name = t['user']?['full_name'] ?? 'Staff Member';
                                return DropdownMenuItem<dynamic>(
                                  value: t,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedTrainer = val);
                              },
                            ),
                            const SizedBox(height: 20),
                            // Date Picker Row
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Session Date', style: TextStyle(color: AppColors.onSurfaceVariant)),
                              subtitle: Text(
                                _selectedDate == null ? 'Not Selected' : _formatDate(_selectedDate!),
                                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              trailing: Icon(Icons.calendar_month, color: _selectedDate == null ? Colors.white30 : AppColors.primaryFixed),
                              onTap: _pickDate,
                            ),
                            const Divider(color: Colors.white12),
                            // Time Picker Row
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Start Time', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                    subtitle: Text(
                                      _startTime == null ? 'Not Selected' : _formatTime(_startTime!),
                                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    trailing: Icon(Icons.access_time, color: _startTime == null ? Colors.white30 : AppColors.primaryFixed),
                                    onTap: _pickStartTime,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('End Time', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                    subtitle: Text(
                                      _endTime == null ? 'Not Selected' : _formatTime(_endTime!),
                                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    trailing: Icon(Icons.access_time, color: _endTime == null ? Colors.white30 : AppColors.primaryFixed),
                                    onTap: _pickEndTime,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _capacityController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Maximum Capacity',
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryFixed)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Capacity required';
                                final val = int.tryParse(value);
                                if (val == null || val <= 0) return 'Must be a positive integer';
                                return null;
                              },
                            ),
                            const SizedBox(height: 36),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _submitSession,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryFixed,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: AppColors.background)
                                  : const Text('SCHEDULE SESSION', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
