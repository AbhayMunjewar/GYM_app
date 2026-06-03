import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIChatApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIChatApp extends StatelessWidget {
  const VelocityAIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VELOCITY AI - Buddy Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const BuddyChatScreen(),
    );
  }
}

// --- MODELS ---
enum Sender { user, ai }

class ChatMessage {
  final String text;
  final Sender sender;
  final Widget? customWidget;

  ChatMessage({required this.text, required this.sender, this.customWidget});
}

// --- MAIN SCREEN ---
class BuddyChatScreen extends StatefulWidget {
  const BuddyChatScreen({super.key});

  @override
  State<BuddyChatScreen> createState() => _BuddyChatScreenState();
}

class _BuddyChatScreenState extends State<BuddyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late List<ChatMessage> messages;

  @override
  void initState() {
    super.initState();
    // Initializing with the default chat from the UI design
    messages = [
      ChatMessage(
        text: 'Hey Velocity! I only have 45 minutes today. Can you give me a focused chest workout for peak activation? I want high intensity.',
        sender: Sender.user,
      ),
      ChatMessage(
        text: '45-Minute Chest Hypertrophy Plan',
        sender: Sender.ai,
        customWidget: const AiWorkoutPlan(),
      ),
    ];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        text: _messageController.text.trim(),
        sender: Sender.user,
      ));
    });

    _messageController.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopAppBar(),
      ),
      body: Row(
        children: [
          if (isDesktop) const DesktopSideNav(),
          Expanded(
            child: Stack(
              children: [
                // Chat List
                ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: 100, 
                    left: 24, 
                    right: 24, 
                    bottom: isDesktop ? 120 : 180, // Extra padding for input area & bottom nav
                  ),
                  itemCount: messages.length + 1, // +1 for follow up suggestions
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const FollowUpSuggestions();
                    }
                    final msg = messages[index];
                    return msg.sender == Sender.user 
                        ? UserMessageBubble(message: msg.text) 
                        : AiMessageBubble(message: msg.text, customWidget: msg.customWidget);
                  },
                ),
                
                // Input Area
                Positioned(
                  bottom: isDesktop ? 24 : 100, // Float above bottom nav on mobile
                  left: 24,
                  right: 24,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 896),
                      child: ChatInputArea(
                        controller: _messageController,
                        onSend: _sendMessage,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop ? const MobileBottomNav() : null,
    );
  }
}

// --- CHAT BUBBLES ---

class UserMessageBubble extends StatelessWidget {
  final String message;
  const UserMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: GlassCard(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(message, style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: kSurface, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: kOnSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }
}

class AiMessageBubble extends StatelessWidget {
  final String message;
  final Widget? customWidget;

  const AiMessageBubble({super.key, required this.message, this.customWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: kPrimary.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('VELOCITY AI BUDDY', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(4)),
                              child: const Text('OPTIMIZED', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(message, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        if (customWidget != null) ...[
                          const SizedBox(height: 24),
                          customWidget!,
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- AI CUSTOM WIDGETS ---

class AiWorkoutPlan extends StatelessWidget {
  const AiWorkoutPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _WorkoutItemCard(title: '1. Barbell Bench Press', icon: Icons.fitness_center, sets: '4', reps: '8-10', rest: '90s')),
                  const SizedBox(width: 16),
                  Expanded(child: _WorkoutItemCard(title: '2. Incline DB Flyes', icon: Icons.swap_horiz, sets: '3', reps: '12', rest: '60s')),
                ],
              );
            }
            return Column(
              children: [
                _WorkoutItemCard(title: '1. Barbell Bench Press', icon: Icons.fitness_center, sets: '4', reps: '8-10', rest: '90s'),
                const SizedBox(height: 16),
                _WorkoutItemCard(title: '2. Incline DB Flyes', icon: Icons.swap_horiz, sets: '3', reps: '12', rest: '60s'),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _WorkoutItemCard(title: '3. Weighted Dips', icon: Icons.expand_more, sets: '3', reps: 'AMRAP', rest: '60s')),
                  const SizedBox(width: 16),
                  Expanded(child: _WorkoutItemCard(title: '4. Cable Crossovers', icon: Icons.join_inner, sets: '2', reps: '15+', rest: '30s', isSecondary: true)),
                ],
              );
            }
             return Column(
              children: [
                _WorkoutItemCard(title: '3. Weighted Dips', icon: Icons.expand_more, sets: '3', reps: 'AMRAP', rest: '60s'),
                const SizedBox(height: 16),
                _WorkoutItemCard(title: '4. Cable Crossovers', icon: Icons.join_inner, sets: '2', reps: '15+', rest: '30s', isSecondary: true),
              ],
            );
          }
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Estimated total time: 42 minutes.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('START SESSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                onPressed: () {},
              )
            ],
          ),
        )
      ],
    );
  }
}

class _WorkoutItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String sets;
  final String reps;
  final String rest;
  final bool isSecondary;

  const _WorkoutItemCard({
    required this.title, 
    required this.icon, 
    required this.sets, 
    required this.reps, 
    required this.rest,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = isSecondary ? kSecondary : kPrimary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: themeColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(icon, color: themeColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Sets', value: sets, color: themeColor)),
              const SizedBox(width: 8),
              Expanded(child: _StatBox(label: 'Reps', value: reps, color: themeColor)),
              const SizedBox(width: 8),
              Expanded(child: _StatBox(label: 'Rest', value: rest, color: themeColor)),
            ],
          )
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FollowUpSuggestions extends StatelessWidget {
  const FollowUpSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, top: 8.0, bottom: 24.0), // Align with AI bubble
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _SuggestionChip(text: 'Adjust for dumbbells only?'),
          _SuggestionChip(text: 'Add triceps finisher?'),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  const _SuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: BorderRadius.circular(20),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputArea({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: kOnSurfaceVariant),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Ask Velocity anything...',
                hintStyle: TextStyle(color: kOnSurfaceVariant),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ),
          InkWell(
            onTap: onSend,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.send, color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}

// --- LAYOUT COMPONENTS ---

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: kBackground.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt, color: kPrimary),
                    SizedBox(width: 8),
                    Text(
                      'VELOCITY AI',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary, letterSpacing: -1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kPrimary),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBRzsEvE9ooDFNJfNplCFViW9dPNG6AtouLcO7YYeWNPjguW9RsG69yPstkMyrJXp8rNn_vUxKIKMkfgf5QuqDjinnfKCUBrwIow3hnOLzQJAJi3dHqgtydWQkNClirDiXZeW5bm2sPJy6q9E0z9VNo1IkhNdXxDZfKsEWPQeQMUsR72hzLfg7fdTMKE4o6GCRu05Z_DrTaj8_DcBTDJAPkd2E8VEDUaupq6jq06q78W4wVpU3aGsaGfqxV7usdOhc92JWQzhRaw_0'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      margin: const EdgeInsets.only(top: 64),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.7),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('VELOCITY', style: TextStyle(color: kPrimary, fontSize: 32, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                const SizedBox(height: 40),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.analytics, title: 'Analytics'),
                _NavTile(icon: Icons.smart_toy, title: 'AI Buddy', isActive: true),
                _NavTile(icon: Icons.group, title: 'Members'),
                _NavTile(icon: Icons.settings, title: 'Settings'),
                const Spacer(),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary.withOpacity(0.5)),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA5WefdTTkN1t2CsmR97bZmLT9w26yhtPTKWAHhGOW_ToQZGP-1nqR4QqVHT4-KT3eA1bm2QAdZc6aYRm9kKG1HgbgI67GhPcRNf6au3OzJQeuw8MxkYB7_nrQfushdyfUIBqURauz9-RkGbjwF54RO_nBo8bwJQjqwB4ZXboGTDrsQG0hfRJY3IKA-g5xlO1wndLRzg5Uk3Yuv5SwsuAT9LVacJLQMPSIk82WLhNdXYk3ewei4ee5iLje9BK76A9AgSeClhNnWto0'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Alex Rivers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('PRO ATHLETE • LVL 42', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _NavTile({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? kPrimary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? const Border(right: BorderSide(color: kPrimary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E).withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home'),
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy', isActive: true),
              _BottomNavIcon(icon: Icons.bar_chart, title: 'Stats'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _BottomNavIcon({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant, size: isActive ? 28 : 24),
        const SizedBox(height: 4),
        Text(
          title.toUpperCase(), 
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant, 
            fontSize: 10, 
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}

// --- UTILITY ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassCard({super.key, required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}