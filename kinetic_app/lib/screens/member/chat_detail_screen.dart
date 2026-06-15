import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic>? targetUser;

  const ChatDetailScreen({
    super.key,
    required this.roomId,
    this.targetUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  List<dynamic> _messages = [];
  WebSocket? _webSocket;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _webSocket?.close();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final res = await _apiClient.getChatMessages(widget.roomId);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _messages = body['results'] ?? body['data'] ?? [];
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectWebSocket() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      // Map HTTP baseUrl to WebSocket scheme
      final rawBaseUrl = _apiClient.baseUrl;
      final wsBaseUrl = rawBaseUrl.replaceAll('http://', 'ws://').replaceAll('https://', 'wss://');
      final wsUrl = '$wsBaseUrl/api/chat/ws/chat/${widget.roomId}/?token=$token'; 
      // Wait, let's look at routing: it's standard /ws/chat/{room_id}/
      final wsCorrectUrl = '$wsBaseUrl/ws/chat/${widget.roomId}/?token=$token';

      print('Connecting to WebSocket: $wsCorrectUrl');
      _webSocket = await WebSocket.connect(wsCorrectUrl);
      
      _webSocket!.listen(
        (data) {
          final parsed = jsonDecode(data);
          if (parsed['success'] == true || parsed['data'] != null) {
            final msg = parsed['data'] ?? parsed;
            setState(() {
              _messages.add(msg);
            });
            _scrollToBottom();
          }
        },
        onError: (err) {
          print('WebSocket Error: $err');
          _reconnect();
        },
        onDone: () {
          print('WebSocket Connection Closed');
          _reconnect();
        },
      );
    } catch (e) {
      print('WebSocket Connection Failure: $e');
      _reconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _connectWebSocket();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      _webSocket!.add(jsonEncode({
        'content': text,
        'message_type': 'TEXT',
      }));
      _messageController.clear();
    } else {
      // Fallback to REST API if WebSocket is offline
      _apiClient.post('/api/chat/messages/', {
        'room': widget.roomId,
        'content': text,
        'message_type': 'TEXT',
      }).then((res) {
        if (res.statusCode == 201) {
          _messageController.clear();
          _loadMessages();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipientName = widget.targetUser?['full_name'] ?? 'Chat';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(recipientName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : _messages.isEmpty
                      ? const Center(child: Text('Say hello to start the conversation!', style: TextStyle(color: AppColors.onSurfaceVariant)))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final bool isMe = msg['sender_details']?['email'] == authService.email;
                            final content = msg['content'] ?? '';
                            final sentAtStr = msg['sent_at'] ?? msg['created_at'] ?? '';
                            
                            DateTime time = DateTime.now();
                            if (sentAtStr.isNotEmpty) {
                              time = DateTime.tryParse(sentAtStr) ?? DateTime.now();
                            }
                            final timeStr = DateFormat('hh:mm a').format(time);

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primaryFixed : const Color(0xFF1E1C1C),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                  ),
                                  border: isMe ? null : Border.all(color: AppColors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content,
                                      style: TextStyle(
                                        color: isMe ? AppColors.background : Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        color: isMe ? AppColors.background.withOpacity(0.6) : AppColors.onSurfaceVariant,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const Divider(color: AppColors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                        filled: true,
                        fillColor: const Color(0xFF1E1C1C),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryFixed,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.background, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
