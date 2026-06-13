import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

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
  
  bool _isLoading = true;
  bool _isMoreLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  List<dynamic> _posts = [];
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
    _loadFeed(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isMoreLoading && _hasMore) {
        _loadFeed();
      }
    }
  }

  Future<void> _loadFeed({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _isLoading = true;
        _hasMore = true;
        _posts = [];
      });
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
      setState(() {
        _isLoading = false;
        _isMoreLoading = false;
      });
    }
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final content = _postController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and content')),
      );
      return;
    }

    setState(() => _isLoading = true);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!'), backgroundColor: Colors.green),
        );
        _loadFeed(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to publish post'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleReaction(int index, String reactionType) async {
    final post = _posts[index];
    final postId = post['id'];
    final bool currentLiked = post['liked_by_user'] ?? false;
    final String? currentReaction = post['user_reaction_type'];

    // Optimistic UI updates
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
    } catch (e) {
      // Revert optimistic updates on failure
      _loadFeed(refresh: true);
    }
  }

  void _showCommentSheet(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentBottomSheet(postId: postId),
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
        title: const Text('COMMUNITY HUB', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Post Publisher Box
            _buildPostCreatorBox(),
            const Divider(color: AppColors.white10, height: 1),
            // Community Posts Feed
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : RefreshIndicator(
                      color: AppColors.primaryFixed,
                      onRefresh: () => _loadFeed(refresh: true),
                      child: _posts.isEmpty
                          ? const Center(child: Text('Be the first to share something!', style: TextStyle(color: AppColors.onSurfaceVariant)))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: _posts.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _posts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryFixed)),
                                  );
                                }
                                return _buildPostCard(index);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

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
              // Post Type Chip Selector
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
    final int comments = post['comments_count'] ?? 0;
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
          // Post Header
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
              // Category tag badge
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
          // Post Title & Content
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
          // Social Action Button Bar
          Row(
            children: [
              // Like/Reaction Button with drawer trigger
              GestureDetector(
                onTap: () => _toggleReaction(index, 'LIKE'),
                onLongPress: () {
                  // Show micro-animated reactions picker
                  _showReactionsPicker(context, (reaction) {
                    Navigator.pop(context);
                    _toggleReaction(index, reaction);
                  });
                },
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
              const SizedBox(width: 12),
              // Comments Button
              GestureDetector(
                onTap: () => _showCommentSheet(post['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$comments',
                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              )
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

  void _showReactionsPicker(BuildContext context, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF282626),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReactionPickerItem('LIKE', Icons.thumb_up, Colors.blue, onSelect),
              _buildReactionPickerItem('FIRE', Icons.local_fire_department, Colors.orange, onSelect),
              _buildReactionPickerItem('CLAP', Icons.workspace_premium, Colors.yellow, onSelect),
              _buildReactionPickerItem('STRONG', Icons.fitness_center, Colors.red, onSelect),
              _buildReactionPickerItem('MOTIVATED', Icons.bolt, Colors.purple, onSelect),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionPickerItem(String val, IconData icon, Color color, Function(String) onSelect) {
    return InkWell(
      onTap: () => onSelect(val),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  final String postId;
  const _CommentBottomSheet({required this.postId});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _commentController = TextEditingController();
  
  bool _isLoading = true;
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final res = await _apiClient.getPostComments(widget.postId);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _comments = body['results'] ?? body['data'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final res = await _apiClient.addComment(widget.postId, {'content': text});
      if (res.statusCode == 201 || res.statusCode == 200) {
        _commentController.clear();
        _loadComments();
      }
    } catch (e) {
      print('Error posting comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      height: media.size.height * 0.75 + media.viewInsets.bottom,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: media.viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('COMMENTS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                : _comments.isEmpty
                    ? const Center(child: Text('No comments yet.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
                      ),
          ),
          const Divider(color: AppColors.white10, height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                    filled: true,
                    fillColor: AppColors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primaryFixed),
                onPressed: _postComment,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(dynamic comment) {
    final author = comment['author_details'] ?? {};
    final content = comment['content'] ?? '';
    final replies = comment['replies'] ?? [];
    final created = DateTime.tryParse(comment['created_at'] ?? '') ?? DateTime.now();
    final timeStr = DateFormat('MMM dd, hh:mm a').format(created);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: author['profile_image'] != null ? NetworkImage(author['profile_image']) : null,
                backgroundColor: AppColors.primaryFixed.withOpacity(0.1),
                child: author['profile_image'] == null ? const Icon(Icons.person, color: AppColors.primaryFixed, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, height: 1.3),
                        children: [
                          TextSpan(
                            text: author['full_name'] ?? 'User',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: content,
                            style: const TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(timeStr, style: const TextStyle(color: AppColors.white30, fontSize: 11)),
                  ],
                ),
              )
            ],
          ),
        ),
        // Render direct replies indented
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 36.0, top: 4, bottom: 4),
            child: Column(
              children: (replies as List).map<Widget>((reply) {
                final replyAuthor = reply['author_details'] ?? {};
                final replyContent = reply['content'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: replyAuthor['profile_image'] != null ? NetworkImage(replyAuthor['profile_image']) : null,
                        backgroundColor: AppColors.primaryFixed.withOpacity(0.1),
                        child: replyAuthor['profile_image'] == null ? const Icon(Icons.person, color: AppColors.primaryFixed, size: 12) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12, height: 1.3),
                            children: [
                              TextSpan(
                                text: replyAuthor['full_name'] ?? 'User',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: replyContent,
                                style: const TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          )
      ],
    );
  }
}
