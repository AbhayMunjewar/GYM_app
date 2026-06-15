import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final ApiClient _apiClient = ApiClient();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Q&A form controllers
  final TextEditingController _qTitleController = TextEditingController();
  final TextEditingController _qContentController = TextEditingController();
  
  // Group creation form controllers
  final TextEditingController _gNameController = TextEditingController();
  final TextEditingController _gDescController = TextEditingController();
  
  // Topic creation controllers
  final TextEditingController _tTitleController = TextEditingController();
  final TextEditingController _tContentController = TextEditingController();

  bool _isLoading = true;
  bool _isMoreLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  
  // General lists
  List<dynamic> _posts = [];
  List<dynamic> _groups = [];
  List<dynamic> _forumCategories = [];
  List<dynamic> _events = [];
  List<dynamic> _questions = [];
  List<dynamic> _reports = [];

  String _selectedPostType = 'GENERAL';
  final List<Map<String, String>> _postTypes = [
    {'value': 'GENERAL', 'label': 'General'},
    {'value': 'PROGRESS', 'label': 'Progress'},
    {'value': 'WORKOUT', 'label': 'Workout'},
    {'value': 'DIET', 'label': 'Diet'},
    {'value': 'CHALLENGE', 'label': 'Challenge'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    _titleController.dispose();
    _qTitleController.dispose();
    _qContentController.dispose();
    _gNameController.dispose();
    _gDescController.dispose();
    _tTitleController.dispose();
    _tContentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isMoreLoading && _hasMore) {
        _loadFeed();
      }
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadFeed(refresh: true),
      _loadGroups(),
      _loadForums(),
      _loadEvents(),
      _loadQuestions(),
      if (authService.currentRole == UserRole.owner || authService.currentRole == UserRole.trainer)
        _loadReports(),
    ]);
    setState(() => _isLoading = false);
  }

  // --- 1. Community Feed Helpers ---
  Future<void> _loadFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _posts = [];
    } else {
      setState(() => _isMoreLoading = true);
    }

    try {
      final res = await _apiClient.getCommunityFeed(page: _currentPage);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List<dynamic> fetchedPosts = body['results'] ?? body['data'] ?? [];
        setState(() {
          _posts.addAll(fetchedPosts);
          _currentPage++;
          _hasMore = fetchedPosts.length >= 20;
        });
      }
    } catch (e) {
      print('Error loading community feed: $e');
    } finally {
      if (!refresh) {
        setState(() => _isMoreLoading = false);
      }
    }
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final content = _postController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    try {
      final res = await _apiClient.createCommunityPost({
        'title': title,
        'content': content,
        'post_type': _selectedPostType,
        'visibility': 'GYM_ONLY',
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        _titleController.clear();
        _postController.clear();
        _loadFeed(refresh: true);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleReaction(int index, String reactionType) async {
    final post = _posts[index];
    final postId = post['id'];
    final bool currentLiked = post['liked_by_user'] ?? false;
    final String? currentReaction = post['user_reaction_type'];

    setState(() {
      if (currentLiked && currentReaction == reactionType) {
        _posts[index]['liked_by_user'] = false;
        _posts[index]['user_reaction_type'] = null;
        _posts[index]['reactions_count'] = (_posts[index]['reactions_count'] ?? 1) - 1;
      } else {
        _posts[index]['liked_by_user'] = true;
        _posts[index]['user_reaction_type'] = reactionType;
        if (!currentLiked) {
          _posts[index]['reactions_count'] = (_posts[index]['reactions_count'] ?? 0) + 1;
        }
      }
    });

    try {
      if (currentLiked && currentReaction == reactionType) {
        await _apiClient.deleteReaction(postId);
      } else {
        await _apiClient.reactToPost(postId, reactionType);
      }
    } catch (_) {
      _loadFeed(refresh: true);
    }
  }

  // --- 2. Groups Helpers ---
  Future<void> _loadGroups() async {
    try {
      final res = await _apiClient.getGroups();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _groups = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleGroupJoin(int index) async {
    final group = _groups[index];
    final bool isMember = group['is_member'] ?? false;

    try {
      final res = isMember 
          ? await _apiClient.leaveGroup(group['id']) 
          : await _apiClient.joinGroup(group['id']);

      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          _groups[index]['is_member'] = !isMember;
          _groups[index]['members_count'] = isMember 
              ? (group['members_count'] ?? 1) - 1 
              : (group['members_count'] ?? 0) + 1;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _createGroup() async {
    final name = _gNameController.text.trim();
    final desc = _gDescController.text.trim();
    if (name.isEmpty || desc.isEmpty) return;

    try {
      final res = await _apiClient.createGroup({
        'group_name': name,
        'description': desc,
        'group_type': 'PUBLIC'
      });
      if (res.statusCode == 201) {
        _gNameController.clear();
        _gDescController.clear();
        Navigator.pop(context);
        _loadGroups();
      }
    } catch (e) {
      print(e);
    }
  }

  // --- 3. Forum Helpers ---
  Future<void> _loadForums() async {
    try {
      final res = await _apiClient.getForumCategories();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _forumCategories = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // --- 4. Events Helpers ---
  Future<void> _loadEvents() async {
    try {
      final res = await _apiClient.getEvents();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _events = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleEventRegistration(int index) async {
    final event = _events[index];
    final bool isReg = event['is_registered'] ?? false;

    try {
      final res = isReg 
          ? await _apiClient.cancelEventRegistration(event['id'])
          : await _apiClient.registerForEvent(event['id']);

      if (res.statusCode == 200) {
        setState(() {
          _events[index]['is_registered'] = !isReg;
          _events[index]['registrations_count'] = isReg 
              ? (event['registrations_count'] ?? 1) - 1 
              : (event['registrations_count'] ?? 0) + 1;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // --- 5. Q&A Helpers ---
  Future<void> _loadQuestions() async {
    try {
      final res = await _apiClient.getQuestions();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _questions = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _askQuestion() async {
    final title = _qTitleController.text.trim();
    final content = _qContentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    try {
      final res = await _apiClient.askQuestion({
        'title': title,
        'question': content,
      });
      if (res.statusCode == 201) {
        _qTitleController.clear();
        _qContentController.clear();
        Navigator.pop(context);
        _loadQuestions();
      }
    } catch (e) {
      print(e);
    }
  }

  // --- 6. Moderation Helpers ---
  Future<void> _loadReports() async {
    try {
      final res = await _apiClient.getReports();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _reports = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _resolveReport(String reportId, String action) async {
    try {
      final res = await _apiClient.resolveReport(reportId, action);
      if (res.statusCode == 200) {
        _loadReports();
        _loadFeed(refresh: true);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isStaff = authService.currentRole == UserRole.owner || authService.currentRole == UserRole.trainer;
    final int tabCount = isStaff ? 6 : 5;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text('COMMUNITY HUB', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryFixed),
              onPressed: () => context.push('/member/chat-rooms'),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primaryFixed,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            tabs: [
              const Tab(text: 'FEED'),
              const Tab(text: 'GROUPS'),
              const Tab(text: 'FORUMS'),
              const Tab(text: 'EVENTS'),
              const Tab(text: 'Q&A'),
              if (isStaff) const Tab(text: 'MODERATION'),
            ],
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
              : TabBarView(
                  children: [
                    _buildFeedTab(),
                    _buildGroupsTab(),
                    _buildForumsTab(),
                    _buildEventsTab(),
                    _buildQATab(),
                    if (isStaff) _buildModerationTab(),
                  ],
                ),
        ),
      ),
    );
  }

  // --- TAB 1: COMMUNITY FEED ---
  Widget _buildFeedTab() {
    return Column(
      children: [
        _buildPostCreatorBox(),
        const Divider(color: AppColors.white10, height: 1),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryFixed,
            onRefresh: () => _loadFeed(refresh: true),
            child: _posts.isEmpty
                ? const Center(child: Text('Be the first to share something!', style: TextStyle(color: AppColors.onSurfaceVariant)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) => _buildPostCard(index),
                  ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: GROUPS ---
  Widget _buildGroupsTab() {
    final bool canCreate = authService.currentRole == UserRole.owner || authService.currentRole == UserRole.trainer;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canCreate)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.group_add),
                label: const Text('CREATE NEW GROUP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.background,
                ),
                onPressed: _showCreateGroupDialog,
              ),
            ),
          Expanded(
            child: _groups.isEmpty
                ? const Center(child: Text('No active groups.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                : ListView.builder(
                    itemCount: _groups.length,
                    itemBuilder: (context, index) {
                      final g = _groups[index];
                      final bool isMember = g['is_member'] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1C1C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.white10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g['group_name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(g['description'] ?? '', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Text('${g['members_count'] ?? 0} Members', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMember ? Colors.redAccent : AppColors.primaryFixed,
                                foregroundColor: isMember ? Colors.white : AppColors.background,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _toggleGroupJoin(index),
                              child: Text(isMember ? 'LEAVE' : 'JOIN', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282626),
        title: const Text('New Fitness Group', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _gNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Group Name',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gDescController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: _createGroup, child: const Text('CREATE', style: TextStyle(color: AppColors.primaryFixed))),
        ],
      ),
    );
  }

  // --- TAB 3: DISCUSSION FORUMS ---
  Widget _buildForumsTab() {
    return _forumCategories.isEmpty
        ? const Center(child: Text('No forum categories setup.', style: TextStyle(color: AppColors.onSurfaceVariant)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _forumCategories.length,
            itemBuilder: (context, index) {
              final cat = _forumCategories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C1C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white10),
                ),
                child: ListTile(
                  title: Text(cat['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(cat['description'] ?? '', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(20)),
                    child: Text('${cat['topics_count'] ?? 0} Topics', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              );
            },
          );
  }

  // --- TAB 4: EVENTS ---
  Widget _buildEventsTab() {
    return _events.isEmpty
        ? const Center(child: Text('No upcoming community events.', style: TextStyle(color: AppColors.onSurfaceVariant)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final ev = _events[index];
              final bool isRegistered = ev['is_registered'] ?? false;
              final start = DateTime.tryParse(ev['start_date'] ?? '') ?? DateTime.now();
              final dateStr = DateFormat('MMM dd, hh:mm a').format(start);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C1C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ev['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(ev['description'] ?? '', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.event, color: AppColors.primaryFixed, size: 14),
                              const SizedBox(width: 6),
                              Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered ? Colors.grey : AppColors.primaryFixed,
                        foregroundColor: isRegistered ? Colors.white : AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _toggleEventRegistration(index),
                      child: Text(isRegistered ? 'CANCEL' : 'RSVP', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          );
  }

  // --- TAB 5: TRAINER Q&A ---
  Widget _buildQATab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.help_outline),
            label: const Text('ASK COACH A QUESTION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.background,
            ),
            onPressed: _showAskQuestionDialog,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _questions.isEmpty
                ? const Center(child: Text('No Q&A topics yet.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                : ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final q = _questions[index];
                      final answers = q['answers'] as List? ?? [];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1C1C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(q['question'] ?? '', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                            const Divider(color: AppColors.white10, height: 16),
                            if (answers.isEmpty)
                              const Text('Pending trainer answer...', style: TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic))
                            else ...[
                              const Text('Answers:', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ...answers.map((ans) => Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Coach: ${ans['answer']}',
                                      style: const TextStyle(color: AppColors.primaryFixed, fontSize: 13),
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAskQuestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282626),
        title: const Text('Ask a Trainer', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _qTitleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Topic Title',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qContentController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Your Question',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: _askQuestion, child: const Text('ASK', style: TextStyle(color: AppColors.primaryFixed))),
        ],
      ),
    );
  }

  // --- TAB 6: MODERATION QUEUE (Staff Only) ---
  Widget _buildModerationTab() {
    return _reports.isEmpty
        ? const Center(child: Text('Clean moderation queue!', style: TextStyle(color: AppColors.onSurfaceVariant)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              final r = _reports[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C1C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Report type: ${r['content_type']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(r['status'] ?? 'PENDING', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Reason: ${r['reason']}', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                    const SizedBox(height: 12),
                    if (r['status'] == 'PENDING')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _resolveReport(r['id'], 'RESOLVED'),
                            child: const Text('DISMISS', style: TextStyle(color: Colors.white54)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () => _resolveReport(r['id'], 'HIDE'),
                            child: const Text('HIDE / DELETE'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
  }

  // --- UTILS: POST CARDS ---
  Widget _buildPostCreatorBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1C1C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryFixed.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primaryFixed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: "Give it a title...",
                        hintStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _postController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind? Share workouts, diet tips...",
                        hintStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _selectedPostType,
                dropdownColor: const Color(0xFF282626),
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryFixed),
                style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 13),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPostType = val);
                },
                items: _postTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final post = _posts[index];
    final author = post['author_details'] ?? {};
    final title = post['title'] ?? 'Title';
    final content = post['content'] ?? '';
    final type = post['post_type'] ?? 'GENERAL';
    final created = DateTime.tryParse(post['created_at'] ?? '') ?? DateTime.now();
    final timeStr = DateFormat('MMM dd, hh:mm a').format(created);
    
    final int reactions = post['reactions_count'] ?? 0;
    final bool liked = post['liked_by_user'] ?? false;
    final String? userReaction = post['user_reaction_type'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: author['profile_image'] != null ? NetworkImage(author['profile_image']) : null,
                backgroundColor: AppColors.primaryFixed.withOpacity(0.1),
                child: author['profile_image'] == null ? const Icon(Icons.person, color: AppColors.primaryFixed) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author['full_name'] ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            author['role_display'] ?? author['role'] ?? 'MEMBER',
                            style: const TextStyle(color: AppColors.primaryFixed, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(timeStr, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: const TextStyle(color: AppColors.secondaryContainer, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleReaction(index, 'LIKE'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: liked ? AppColors.primaryFixed.withOpacity(0.1) : AppColors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getReactionIcon(userReaction),
                        color: liked ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$reactions',
                        style: TextStyle(color: liked ? AppColors.primaryFixed : AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  IconData _getReactionIcon(String? reactionType) {
    switch (reactionType) {
      case 'FIRE': return Icons.local_fire_department;
      case 'CLAP': return Icons.workspace_premium;
      case 'STRONG': return Icons.fitness_center;
      case 'MOTIVATED': return Icons.bolt;
      default: return Icons.thumb_up;
    }
  }
}
