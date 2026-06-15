import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getChatRooms();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _rooms = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading rooms: $e');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('MESSAGES', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : _rooms.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant, size: 48),
                        SizedBox(height: 16),
                        Text('No active messages yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primaryFixed,
                    onRefresh: _loadRooms,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        final participants = room['participants'] as List? ?? [];
                        
                        // Find the other participant
                        final recipientPart = participants.firstWhere(
                          (p) => p['user_details']?['email'] != authService.email,
                          orElse: () => null,
                        );

                        if (recipientPart == null) return const SizedBox();

                        final recipient = recipientPart['user_details'] ?? {};
                        final lastMsg = room['last_message'] ?? {};
                        final int unreadCount = room['unread_count'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1C1C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.white10),
                          ),
                          child: ListTile(
                            onTap: () {
                              context.push('/member/chat/${room['id']}', extra: recipient).then((_) => _loadRooms());
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: recipient['profile_image'] != null
                                  ? NetworkImage(recipient['profile_image'])
                                  : null,
                              backgroundColor: AppColors.primaryFixed.withOpacity(0.1),
                              child: recipient['profile_image'] == null
                                  ? const Icon(Icons.person, color: AppColors.primaryFixed)
                                  : null,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  recipient['full_name'] ?? 'Recipient',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryFixed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(color: AppColors.background, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                lastMsg['content'] ?? 'Tap to chat',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
