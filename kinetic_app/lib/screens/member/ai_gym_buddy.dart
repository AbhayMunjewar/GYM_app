import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AIGymBuddy extends StatelessWidget {
  const AIGymBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('AI GYM BUDDY', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildMessage('Hey! Ready for your Upper Body Power session?', isAI: true),
                  _buildMessage('Yeah, but my left shoulder feels a bit tight today.', isAI: false),
                  _buildMessage('Got it. Let\'s swap the Barbell Bench Press for Dumbbell Floor Presses to reduce shoulder strain. Sounds good?', isAI: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask Velocity AI...',
                        filled: true,
                        fillColor: const Color(0xFF201F1F),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: const BoxDecoration(color: AppColors.primaryFixed, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send, color: AppColors.onPrimaryFixed), onPressed: () {}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, {required bool isAI}) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isAI ? const Color(0xFF201F1F) : AppColors.primaryFixed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: !isAI ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: Border.all(color: isAI ? Colors.transparent : AppColors.primaryFixed.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: TextStyle(color: isAI ? AppColors.white : AppColors.primaryFixed)),
      ),
    );
  }
}
