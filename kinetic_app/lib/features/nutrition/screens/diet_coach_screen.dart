import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../providers/nutrition_providers.dart';

class DietCoachScreen extends ConsumerStatefulWidget {
  const DietCoachScreen({super.key});

  @override
  ConsumerState<DietCoachScreen> createState() => _DietCoachScreenState();
}

class _DietCoachScreenState extends ConsumerState<DietCoachScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickReplies = [
    "What to eat before workout?",
    "Replace chicken with paneer?",
    "₹200/day diet plan",
    "I'm vegetarian",
    "Help me gain muscle",
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _msgController.text.trim();
    if (messageText.isEmpty) return;

    if (text == null) {
      _msgController.clear();
    }

    final profile = ref.read(nutritionProfileProvider).profile ?? {};
    final activeContext = {
      'age': profile['age'] ?? 25,
      'gender': profile['gender'] ?? 'Male',
      'goal': profile['goal'] ?? 'maintenance',
      'weight_kg': profile['weight_kg'] ?? 70.0,
      'height_cm': profile['height_cm'] ?? 170.0,
      'budget_inr': profile['budget_inr'] ?? 200,
      'food_preference': profile['food_preference'] ?? 'veg',
      'allergies': profile['allergies'] ?? 'none',
      'medical_restrictions': profile['medical_restrictions'] ?? 'none'
    };

    ref.read(dietCoachProvider.notifier).sendMessage(messageText, activeContext).then((_) {
      _scrollToBottom();
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final coachState = ref.watch(dietCoachProvider);

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
          'AI DIET COACH',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSafetyBanner(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: coachState.messages.length,
                itemBuilder: (context, index) {
                  final msg = coachState.messages[index];
                  return _buildChatBubble(msg);
                },
              ),
            ),
            if (coachState.isTyping) _buildTypingIndicator(),
            _buildQuickRepliesRow(),
            _buildInputPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.05),
      child: const Row(
        children: [
          Icon(Icons.security, color: Colors.orange, size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "NutriCoach answers are for informational purposes only. Consult doctor if on medical treatment.",
              style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatBubble(CoachMessage msg) {
    final alignRight = msg.isUser;
    final timeStr = DateFormat('hh:mm a').format(msg.timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!alignRight) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white10,
              child: Icon(Icons.smart_toy, color: AppColors.primaryFixed, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: alignRight ? AppColors.primaryFixed : const Color(0xFF201F1F),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(alignRight ? 16 : 0),
                  bottomRight: Radius.circular(alignRight ? 0 : 16),
                ),
                border: Border.all(color: alignRight ? Colors.transparent : AppColors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: alignRight ? AppColors.onPrimaryFixed : AppColors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        color: alignRight ? Colors.black38 : Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (alignRight) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white10,
              child: Icon(Icons.person, color: AppColors.white, size: 16),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.white10,
            child: Icon(Icons.smart_toy, color: AppColors.primaryFixed, size: 12),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "NutriCoach is typing...",
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRepliesRow() {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              backgroundColor: const Color(0xFF201F1F),
              side: BorderSide(color: AppColors.white.withOpacity(0.05)),
              label: Text(
                reply,
                style: const TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _sendMessage(reply),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        border: Border(top: BorderSide(color: AppColors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your diet question here...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                fillColor: const Color(0xFF201F1F),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryFixed,
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.onPrimaryFixed, size: 18),
              onPressed: () => _sendMessage(),
            ),
          )
        ],
      ),
    );
  }
}
