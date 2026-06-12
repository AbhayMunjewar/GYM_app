import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class ClientManagement extends StatefulWidget {
  const ClientManagement({super.key});

  @override
  State<ClientManagement> createState() => _ClientManagementState();
}

class _ClientManagementState extends State<ClientManagement> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _clients = [];
  bool _isLoading = true;
  String _errorMsg = '';
  String? _trainerId;

  @override
  void initState() {
    super.initState();
    _fetchTrainerIdAndClients();
  }

  Future<void> _fetchTrainerIdAndClients({String query = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      // 1. Fetch dashboard stats to get trainer_id if not already fetched
      if (_trainerId == null) {
        final dashRes = await _apiClient.getTrainerDashboardStats();
        if (dashRes.statusCode == 200) {
          final dashBody = jsonDecode(dashRes.body);
          if (dashBody['success'] == true) {
            _trainerId = dashBody['data']['trainer_id'];
          }
        }
      }

      if (_trainerId == null) {
        setState(() {
          _errorMsg = 'Trainer profile not found. Please log in with a trainer account.';
          _isLoading = false;
        });
        return;
      }

      // 2. Fetch members list for this trainer
      final res = await _apiClient.getTrainerMembers(
        _trainerId!,
        query: query.isNotEmpty ? 'search=$query' : '',
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List dynamicList = body['data']['results'] ?? body['data'];
          setState(() {
            _clients = dynamicList;
          });
        } else {
          setState(() => _errorMsg = body['message'] ?? 'Failed to load client list');
        }
      } else {
        setState(() => _errorMsg = 'Failed to load clients. Code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error connecting to server: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _fetchTrainerIdAndClients(query: query);
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
          'MY ACTIVE CLIENTS',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search clients by name...',
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
                onRefresh: () => _fetchTrainerIdAndClients(query: _searchController.text),
                child: _isLoading && _clients.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                    : _errorMsg.isNotEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Text(
                                    _errorMsg,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _clients.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  const Center(
                                    child: Text(
                                      'No clients assigned to you yet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: _clients.length,
                                itemBuilder: (context, index) {
                                  final client = _clients[index];
                                  final String name = client['full_name'] ?? 'Unnamed Client';
                                  final String plan = client['plan_name'] ?? 'No Active Membership';
                                  final double attPct = (client['attendance_percentage'] ?? 0.0).toDouble();
                                  final String status = client['membership_status'] ?? 'ACTIVE';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF201F1F),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.white10),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryFixed.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.person, color: AppColors.primaryFixed),
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
                                                plan,
                                                style: const TextStyle(
                                                  color: AppColors.onSurfaceVariant,
                                                  fontSize: 12,
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
                                              style: TextStyle(
                                                color: attPct > 70
                                                    ? AppColors.primaryFixed
                                                    : Colors.orangeAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: status == 'ACTIVE'
                                                    ? Colors.green
                                                    : Colors.redAccent,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
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
