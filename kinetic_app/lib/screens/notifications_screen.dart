import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getNotifications();
      if (res.statusCode == 200) {
        _notifications = jsonDecode(res.body)['results'] ?? [];
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _apiClient.markNotificationRead(id);
      _loadData();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.cardColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : _notifications.isEmpty 
          ? Center(child: Text("No notifications.", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final isRead = notif['is_read'] ?? false;
                
                return Card(
                  color: isRead ? AppTheme.cardColor : AppTheme.cardColor.withOpacity(0.8),
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isRead ? Colors.transparent : AppTheme.primary, width: 1),
                  ),
                  child: ListTile(
                    title: Text(notif['title'], style: TextStyle(color: Colors.white, fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(notif['message'], style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 4),
                        Text(notif['created_at'].toString().split('T')[0], style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                    trailing: isRead 
                      ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : IconButton(
                          icon: Icon(Icons.mark_email_read, color: AppTheme.primary),
                          onPressed: () => _markAsRead(notif['id']),
                        ),
                  ),
                );
              },
            ),
    );
  }
}
