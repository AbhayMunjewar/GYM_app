import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class AIGymBuddy extends StatefulWidget {
  const AIGymBuddy({super.key});

  @override
  State<AIGymBuddy> createState() => _AIGymBuddyState();
}

class _AIGymBuddyState extends State<AIGymBuddy> with TickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  String? _conversationId;
  bool _isLoading = false;
  bool _isInsightsLoading = false;
  bool _isBeginnerLoading = false;

  final List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _progressInsights;
  Map<String, dynamic>? _beginnerPlan;

  // Suggested quick prompts
  static const List<Map<String, String>> _quickPrompts = [
    {'icon': '💪', 'text': 'What are alternatives to bench press?'},
    {'icon': '🥦', 'text': 'How much protein should I eat daily?'},
    {'icon': '📋', 'text': 'Give me a beginner workout plan'},
    {'icon': '📈', 'text': 'How is my progress going?'},
    {'icon': '😴', 'text': 'Tips for recovery after intense sessions'},
    {'icon': '🎯', 'text': 'How do I stay motivated?'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Greet the user
    _messages.add({
      'role': 'ASSISTANT',
      'content':
          'Hey! I\'m Velocity AI, your personal gym buddy. 💪\n\nI can help you with:\n• Exercise alternatives\n• Workout programming\n• Nutrition guidance\n• Progress analysis\n• Recovery tips\n\nWhat would you like to know today?',
      'sources_detail': [],
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMsg = {
      'role': 'USER',
      'content': message.trim(),
      'sources_detail': [],
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _inputController.clear();
    });

    _scrollToBottom();

    try {
      final res = await _apiClient.aiChat(
        message.trim(),
        conversationId: _conversationId,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final data = body['data'];
          _conversationId = data['conversation_id']?.toString();
          final aiMsg = data['message'] as Map<String, dynamic>;

          setState(() {
            _messages.add({
              'role': 'ASSISTANT',
              'content': aiMsg['content'] ?? '',
              'sources_detail': aiMsg['sources_detail'] ?? [],
              'created_at': aiMsg['created_at'] ?? DateTime.now().toIso8601String(),
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            'role': 'ASSISTANT',
            'content': 'Sorry, I encountered an error. Please try again.',
            'sources_detail': [],
            'created_at': DateTime.now().toIso8601String(),
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ASSISTANT',
          'content': 'Unable to connect to the server. Please ensure the backend is running.',
          'sources_detail': [],
          'created_at': DateTime.now().toIso8601String(),
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _fetchProgressInsights() async {
    if (_isInsightsLoading) return;
    setState(() => _isInsightsLoading = true);
    try {
      final res = await _apiClient.getProgressInsights();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() => _progressInsights = body['data']);
        }
      }
    } catch (_) {}
    setState(() => _isInsightsLoading = false);
  }

  Future<void> _fetchBeginnerPlan() async {
    if (_isBeginnerLoading) return;
    setState(() => _isBeginnerLoading = true);
    try {
      final res = await _apiClient.getBeginnerPlan();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() => _beginnerPlan = body['data']);
        }
      }
    } catch (_) {}
    setState(() => _isBeginnerLoading = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primaryFixed, AppColors.primaryFixed.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Velocity AI', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('AI Gym Buddy', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryFixed,
          labelColor: AppColors.primaryFixed,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Progress'),
            Tab(text: 'Beginner'),
          ],
          onTap: (index) {
            if (index == 1 && _progressInsights == null) _fetchProgressInsights();
            if (index == 2 && _beginnerPlan == null) _fetchBeginnerPlan();
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildProgressTab(),
          _buildBeginnerTab(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CHAT TAB
  // -------------------------------------------------------------------------
  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildTypingIndicator();
              }
              final msg = _messages[index];
              return _buildMessage(msg);
            },
          ),
        ),
        if (_messages.length == 1) _buildQuickPrompts(),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isAI = msg['role'] == 'ASSISTANT';
    final sources = (msg['sources_detail'] as List<dynamic>?) ?? [];

    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: BoxDecoration(
              color: isAI
                  ? const Color(0xFF1E1E1E)
                  : AppColors.primaryFixed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isAI ? const Radius.circular(4) : const Radius.circular(16),
                bottomRight: !isAI ? const Radius.circular(4) : const Radius.circular(16),
              ),
              border: Border.all(
                color: isAI ? Colors.white12 : AppColors.primaryFixed.withValues(alpha: 0.4),
              ),
            ),
            child: _buildMessageContent(msg['content'] as String, isAI),
          ),
          // Sources
          if (isAI && sources.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Wrap(
                spacing: 6,
                children: sources.take(3).map<Widget>((source) {
                  return GestureDetector(
                    onTap: () => _showArticleSheet(source['id'] as String, source['title'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories, size: 10, color: AppColors.primaryFixed),
                          const SizedBox(width: 4),
                          Text(
                            source['title'] as String,
                            style: TextStyle(fontSize: 10, color: AppColors.primaryFixed),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(String content, bool isAI) {
    // Parse simple markdown-like bold (**text**)
    final spans = <TextSpan>[];
    final parts = content.split('**');
    for (int i = 0; i < parts.length; i++) {
      if (i.isOdd) {
        spans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        spans.add(TextSpan(text: parts[i]));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isAI ? AppColors.white : AppColors.primaryFixed,
          fontSize: 14,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Velocity AI is thinking', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              height: 12,
              child: Stack(
                children: List.generate(3, (i) => Positioned(
                  left: i * 8.0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + i * 200),
                    builder: (_, v, __) => Opacity(
                      opacity: v < 0.5 ? v * 2 : (1 - v) * 2,
                      child: Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Quick questions',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final p = _quickPrompts[i];
                return GestureDetector(
                  onTap: () => _sendMessage(p['text']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${p['icon']} ${p['text']}',
                      style: TextStyle(color: AppColors.primaryFixed, fontSize: 12),
                      maxLines: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask Velocity AI...',
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.primaryFixed),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_inputController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryFixed, AppColors.primaryFixed.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showArticleSheet(String articleId, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ArticleBottomSheet(apiClient: _apiClient, articleId: articleId, title: title),
    );
  }

  // -------------------------------------------------------------------------
  // PROGRESS INSIGHTS TAB
  // -------------------------------------------------------------------------
  Widget _buildProgressTab() {
    if (_isInsightsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed));
    }

    if (_progressInsights == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('AI Progress Analysis', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Get personalized insights on your fitness journey', style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProgressInsights,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Analyze My Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                foregroundColor: AppColors.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    final insights = _progressInsights!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryFixed.withValues(alpha: 0.2), AppColors.primaryFixed.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.smart_toy, color: AppColors.primaryFixed, size: 20),
                    const SizedBox(width: 8),
                    const Text('Velocity AI Analysis', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(insights['overall_summary'] ?? '', style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Weight trend
          if (insights['weight_trend'] != null) ...[
            const Text('Weight Trend', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInsightCard(
              icon: _trendIcon(insights['weight_trend']['direction'] as String),
              iconColor: _trendColor(insights['weight_trend']['direction'] as String),
              title: 'Weight ${(insights['weight_trend']['change'] as num).toStringAsFixed(1)} kg',
              subtitle: insights['weight_trend']['message'] as String,
            ),
            const SizedBox(height: 16),
          ],

          // Streak insight
          if (insights['streak_insight'] != null) ...[
            const Text('Streak', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInsightCard(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              title: 'Attendance Streak',
              subtitle: insights['streak_insight'] as String,
            ),
            const SizedBox(height: 16),
          ],

          // Goal insights
          if ((insights['goal_insights'] as List).isNotEmpty) ...[
            const Text('Goals', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...(insights['goal_insights'] as List).map((gi) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildInsightCard(
                icon: Icons.flag,
                iconColor: Colors.green,
                title: (gi['goal_type'] as String).replaceAll('_', ' '),
                subtitle: gi['message'] as String,
                progress: (gi['progress'] as num).toDouble(),
              ),
            )).toList(),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if ((insights['recommendations'] as List).isNotEmpty) ...[
            const Text('Recommendations', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: (insights['recommendations'] as List).map<Widget>((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec as String, style: const TextStyle(color: AppColors.white, fontSize: 13, height: 1.4))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _fetchProgressInsights,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Analysis'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryFixed,
                side: BorderSide(color: AppColors.primaryFixed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(iconColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text('${progress.toStringAsFixed(0)}% complete', style: TextStyle(color: iconColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  IconData _trendIcon(String direction) {
    switch (direction) {
      case 'down': return Icons.trending_down;
      case 'up': return Icons.trending_up;
      default: return Icons.trending_flat;
    }
  }

  Color _trendColor(String direction) {
    switch (direction) {
      case 'down': return Colors.green;
      case 'up': return Colors.orange;
      default: return Colors.blue;
    }
  }

  // -------------------------------------------------------------------------
  // BEGINNER PLAN TAB
  // -------------------------------------------------------------------------
  Widget _buildBeginnerTab() {
    if (_isBeginnerLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed));
    }

    if (_beginnerPlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('7-Day Beginner Plan', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('AI-generated starter plan based on your profile', style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchBeginnerPlan,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Generate My Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                foregroundColor: AppColors.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    final plan = _beginnerPlan!;
    final weekPlan = plan['week_plan'] as List<dynamic>? ?? [];
    final exercises = plan['recommended_exercises'] as List<dynamic>? ?? [];
    final nutritionTips = plan['nutrition_tips'] as List<dynamic>? ?? [];
    final keyAdvice = plan['key_advice'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryFixed.withValues(alpha: 0.2), const Color(0xFF1A1A1A)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('7-Day Starter Plan', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Designed for ${plan['member_name'] ?? 'you'} — 3 workouts, 2 rest days, 1 cardio, 1 complete rest', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Week calendar
          const Text('WEEKLY SCHEDULE', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...weekPlan.map((day) => _buildDayCard(day as Map<String, dynamic>)).toList(),

          const SizedBox(height: 20),

          // Key advice
          if (keyAdvice.isNotEmpty) ...[
            const Text('KEY PRINCIPLES', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: keyAdvice.asMap().entries.map<Widget>((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${entry.key + 1}', style: TextStyle(color: AppColors.primaryFixed, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.value as String, style: const TextStyle(color: AppColors.white, fontSize: 13, height: 1.4))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Recommended exercises
          if (exercises.isNotEmpty) ...[
            const Text('RECOMMENDED EXERCISES', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...exercises.map((e) => _buildExerciseCard(e as Map<String, dynamic>)).toList(),
          ],

          // Nutrition tips
          if (nutritionTips.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('NUTRITION ESSENTIALS', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...nutritionTips.map((n) => _buildNutritionCard(n as Map<String, dynamic>)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final type = day['type'] as String;
    final Color typeColor;
    final IconData typeIcon;

    switch (type) {
      case 'workout':
        typeColor = AppColors.primaryFixed;
        typeIcon = Icons.fitness_center;
        break;
      case 'cardio':
        typeColor = Colors.blue;
        typeIcon = Icons.directions_run;
        break;
      case 'rest':
        typeColor = Colors.green;
        typeIcon = Icons.self_improvement;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${day['day']}', style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day['day_name'] as String, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(day['focus'] as String, style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeIcon, size: 12, color: typeColor),
                const SizedBox(width: 4),
                Text(type.toUpperCase(), style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fitness_center, color: AppColors.primaryFixed, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(exercise['title'] as String, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (exercise['difficulty'] as String).toUpperCase(),
                        style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(exercise['summary'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(Map<String, dynamic> nutrition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.orange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nutrition['title'] as String, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(nutrition['summary'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Article Bottom Sheet
// -------------------------------------------------------------------------
class _ArticleBottomSheet extends StatefulWidget {
  final ApiClient apiClient;
  final String articleId;
  final String title;

  const _ArticleBottomSheet({
    required this.apiClient,
    required this.articleId,
    required this.title,
  });

  @override
  State<_ArticleBottomSheet> createState() => _ArticleBottomSheetState();
}

class _ArticleBottomSheetState extends State<_ArticleBottomSheet> {
  bool _isLoading = true;
  Map<String, dynamic>? _article;

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    try {
      final res = await widget.apiClient.getKnowledgeArticle(widget.articleId);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _article = body['data'];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_stories, color: AppColors.primaryFixed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : _article == null
                      ? const Center(child: Text('Failed to load article', style: TextStyle(color: Colors.white54)))
                      : _buildArticleContent(scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(ScrollController scrollController) {
    final article = _article!;
    final muscleGroups = (article['muscle_groups_list'] as List<dynamic>?) ?? [];
    final equipment = (article['equipment_list'] as List<dynamic>?) ?? [];
    final difficulty = article['difficulty'] as String? ?? '';

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Tags row
        Row(
          children: [
            _buildTag(difficulty, AppColors.primaryFixed),
            const SizedBox(width: 8),
            _buildTag(article['article_type'] as String? ?? '', Colors.white24),
          ],
        ),
        if (muscleGroups.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Muscle Groups', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: muscleGroups.map<Widget>((m) => _buildTag(m.toString(), Colors.green.withValues(alpha: 0.3))).toList(),
          ),
        ],
        if (equipment.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Equipment', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: equipment.map<Widget>((e) => _buildTag(e.toString(), Colors.blue.withValues(alpha: 0.3))).toList(),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 16),
        Text(
          article['content'] as String? ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color == AppColors.primaryFixed ? AppColors.primaryFixed : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
