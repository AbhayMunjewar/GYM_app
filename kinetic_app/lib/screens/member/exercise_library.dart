import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class ExerciseLibrary extends StatefulWidget {
  const ExerciseLibrary({super.key});

  @override
  State<ExerciseLibrary> createState() => _ExerciseLibraryState();
}

class _ExerciseLibraryState extends State<ExerciseLibrary> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _categories = [];
  List<dynamic> _articles = [];
  String _selectedCategorySlug = '';
  bool _isLoadingCategories = false;
  bool _isLoadingArticles = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchArticles();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final res = await _apiClient.getKnowledgeCategories();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _categories = body['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchArticles({String? query}) async {
    setState(() => _isLoadingArticles = true);
    try {
      final res = await _apiClient.searchKnowledge(
        query ?? _searchController.text,
        category: _selectedCategorySlug,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _articles = body['data']['results'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error fetching articles: $e');
    } finally {
      setState(() => _isLoadingArticles = false);
    }
  }

  void _onSearchChanged(String val) {
    // Basic search on submit or search click is safer, but we can do a search trigger
    _fetchArticles(query: val);
  }

  void _selectCategory(String slug) {
    setState(() {
      _selectedCategorySlug = slug;
    });
    _fetchArticles();
  }

  Color _getDifficultyColor(String? diff) {
    if (diff == null) return AppColors.white;
    switch (diff.toUpperCase()) {
      case 'BEGINNER':
        return Colors.greenAccent;
      case 'INTERMEDIATE':
        return Colors.orangeAccent;
      case 'ADVANCED':
        return Colors.redAccent;
      default:
        return AppColors.white;
    }
  }

  Future<void> _viewArticleDetails(String articleId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder(
              future: _apiClient.getKnowledgeArticle(articleId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed)),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: Text('Failed to load article detail', style: TextStyle(color: AppColors.white))),
                  );
                }

                final res = snapshot.data!;
                if (res.statusCode != 200) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: Text('Failed to load article detail', style: TextStyle(color: AppColors.white))),
                  );
                }

                final body = jsonDecode(res.body);
                if (body['success'] != true) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: Text('Failed to load article detail', style: TextStyle(color: AppColors.white))),
                  );
                }

                final article = body['data'];
                final categoryName = article['category']?['name'] ?? 'General';
                final difficulty = article['difficulty'] ?? 'General';
                final tags = article['tags_list'] ?? [];
                final equipment = article['equipment_list'] ?? [];
                final exerciseData = article['exercise_data'];

                return Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(top: BorderSide(color: AppColors.white10, width: 1)),
                  ),
                  child: Column(
                    children: [
                      // Handlebar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.white20, borderRadius: BorderRadius.circular(2)),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.white10,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      categoryName.toUpperCase(),
                                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(difficulty).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: _getDifficultyColor(difficulty).withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      difficulty.toUpperCase(),
                                      style: TextStyle(color: _getDifficultyColor(difficulty), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                article['title'] ?? '',
                                style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (article['summary'] != null && article['summary'].toString().isNotEmpty)
                                Text(
                                  article['summary'],
                                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15, fontStyle: FontStyle.italic),
                                ),
                              const Divider(height: 32, color: AppColors.white10),
                              
                              if (exerciseData != null) ...[
                                const Text('EXERCISE SPECIFICS', style: TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                const SizedBox(height: 12),
                                _buildDetailRow('Movement Pattern', exerciseData['movement_pattern'] ?? 'N/A'),
                                _buildDetailRow('Recommended Reps', exerciseData['reps_range'] ?? '8-12 reps'),
                                _buildDetailRow('Rest Interval', '${exerciseData['rest_seconds'] ?? 90}s'),
                                _buildDetailRow('Calories Estimate', '${exerciseData['calories_per_minute'] ?? 5.5} kcal/min'),
                                const SizedBox(height: 16),

                                if (exerciseData['primary_muscles_list'] != null && (exerciseData['primary_muscles_list'] as List).isNotEmpty) ...[
                                  const Text('Primary Muscles Worked', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  _buildTagWrap(exerciseData['primary_muscles_list'], Colors.amberAccent),
                                  const SizedBox(height: 16),
                                ],

                                if (exerciseData['secondary_muscles_list'] != null && (exerciseData['secondary_muscles_list'] as List).isNotEmpty) ...[
                                  const Text('Secondary Muscles Worked', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  _buildTagWrap(exerciseData['secondary_muscles_list'], AppColors.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                ],

                                if (equipment.isNotEmpty) ...[
                                  const Text('Equipment Needed', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  _buildTagWrap(equipment, AppColors.primaryFixed),
                                  const SizedBox(height: 16),
                                ],

                                if (exerciseData['cues'] != null && exerciseData['cues'].toString().isNotEmpty) ...[
                                  const Text('Coaching Cues', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(8)),
                                    child: Text(exerciseData['cues'], style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4)),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                if (exerciseData['common_mistakes'] != null && exerciseData['common_mistakes'].toString().isNotEmpty) ...[
                                  const Text('Common Mistakes to Avoid', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), border: Border.all(color: Colors.redAccent.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
                                    child: Text(exerciseData['common_mistakes'], style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4)),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],

                              const Text('GUIDE & EXECUTION', style: TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              Text(
                                article['content'] ?? 'No instructions provided.',
                                style: const TextStyle(color: AppColors.white, fontSize: 15, height: 1.6),
                              ),
                              
                              if (tags.isNotEmpty) ...[
                                const Divider(height: 32, color: AppColors.white10),
                                _buildTagWrap(tags, Colors.blueAccent),
                              ],

                              const SizedBox(height: 40),
                              
                              if (article['article_type'] == 'EXERCISE')
                                ElevatedButton(
                                  onPressed: () {
                                    context.pop();
                                    _findAlternatives(article['title'] ?? '');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryFixed,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.swap_horiz, color: AppColors.onPrimaryFixed),
                                      SizedBox(width: 8),
                                      Text('Find AI Swaps / Alternatives', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTagWrap(List<dynamic> list, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: list.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.toString(),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _findAlternatives(String exerciseName) async {
    final TextEditingController constraintController = TextEditingController();
    bool isSearchingAlts = false;
    Map<String, dynamic>? altData;
    String? errorMsg;

    void triggerSearch(StateSetter setModalState) async {
      setModalState(() {
        isSearchingAlts = true;
        errorMsg = null;
      });
      try {
        final res = await _apiClient.getExerciseAlternatives(
          exerciseName,
          constraint: constraintController.text.trim(),
        );
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          if (body['success'] == true) {
            setModalState(() {
              altData = body['data'];
            });
          } else {
            setModalState(() {
              errorMsg = body['message'] ?? 'Failed to get alternatives';
            });
          }
        } else {
          setModalState(() {
            errorMsg = 'Failed to fetch options (Status ${res.statusCode})';
          });
        }
      } catch (e) {
        setModalState(() {
          errorMsg = 'Error: $e';
        });
      } finally {
        setModalState(() {
          isSearchingAlts = false;
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.white10, width: 1)),
              ),
              child: Column(
                children: [
                  // Handlebar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.white20, borderRadius: BorderRadius.circular(2)),
                  ),
                  
                  // Sticky input section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SWAPS FOR $exerciseName',
                          style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: constraintController,
                                decoration: InputDecoration(
                                  hintText: 'Add injury / equipment constraint (e.g. knee pain)...',
                                  hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                  filled: true,
                                  fillColor: AppColors.white10,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: isSearchingAlts ? null : () => triggerSearch(setModalState),
                              style: IconButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                              icon: isSearchingAlts 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.onPrimaryFixed, strokeWidth: 2))
                                : const Icon(Icons.search, color: AppColors.onPrimaryFixed),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.white10, height: 20),

                  // Results list
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (altData == null && !isSearchingAlts && errorMsg == null) {
                          // Trigger initial load
                          Future.microtask(() => triggerSearch(setModalState));
                        }

                        if (isSearchingAlts && altData == null) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed));
                        }

                        if (errorMsg != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(errorMsg!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                            ),
                          );
                        }

                        if (altData == null) {
                          return const Center(child: Text('Enter constraints or search to find swaps', style: TextStyle(color: AppColors.onSurfaceVariant)));
                        }

                        final reasoning = altData!['reasoning'] ?? '';
                        final altsList = altData!['alternatives'] as List? ?? [];

                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          children: [
                            if (reasoning.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed.withOpacity(0.05),
                                  border: Border.all(color: AppColors.primaryFixed.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.smart_toy, color: AppColors.primaryFixed, size: 18),
                                        SizedBox(width: 8),
                                        Text('AI Gym Buddy Insights', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(reasoning, style: const TextStyle(color: AppColors.white, fontSize: 13, height: 1.4)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (altsList.isEmpty)
                              const Center(
                                child: Text('No suitable alternative exercises found.', style: TextStyle(color: AppColors.onSurfaceVariant)),
                              )
                            else ...[
                              const Text('RECOMMENDED SWAPS', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 12),
                              ...altsList.map((alt) {
                                final diff = alt['difficulty'] ?? 'Beginner';
                                final muscles = alt['muscle_groups'] ?? '';
                                return Card(
                                  color: const Color(0xFF1C1B1B),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(alt['title'] ?? '', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(alt['summary'] ?? '', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: _getDifficultyColor(diff).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(diff, style: TextStyle(color: _getDifficultyColor(diff), fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(width: 8),
                                              if (muscles.isNotEmpty)
                                                Expanded(
                                                  child: Text(
                                                    muscles, 
                                                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w600),
                                                    maxLines: 1, 
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right, color: AppColors.white),
                                    onTap: () {
                                      context.pop();
                                      _viewArticleDetails(alt['id']);
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
        title: const Text('FITNESS LIBRARY', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () {
              _fetchCategories();
              _fetchArticles();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search exercises, guides, nutrition...',
                  hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.white),
                          onPressed: () {
                            _searchController.clear();
                            _fetchArticles();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1C1B1B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.white10, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryFixed, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.white10, width: 1),
                  ),
                ),
              ),
            ),

            // Horizontal Categories Chip list
            SizedBox(
              height: 50,
              child: _isLoadingCategories
                  ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primaryFixed, strokeWidth: 2)))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: const Text('ALL'),
                            selected: _selectedCategorySlug.isEmpty,
                            onSelected: (_) => _selectCategory(''),
                            selectedColor: AppColors.primaryFixed,
                            backgroundColor: const Color(0xFF1C1B1B),
                            labelStyle: TextStyle(
                              color: _selectedCategorySlug.isEmpty ? AppColors.onPrimaryFixed : AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        ..._categories.map((cat) {
                          final slug = cat['slug'] ?? '';
                          final name = cat['name'] ?? '';
                          final isSelected = _selectedCategorySlug == slug;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(name.toUpperCase()),
                              selected: isSelected,
                              onSelected: (_) => _selectCategory(slug),
                              selectedColor: AppColors.primaryFixed,
                              backgroundColor: const Color(0xFF1C1B1B),
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.onPrimaryFixed : AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            // Articles Grid/List
            Expanded(
              child: _isLoadingArticles
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                  : _articles.isEmpty
                      ? const Center(
                          child: Text(
                            'No items found in the library.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          itemCount: _articles.length,
                          itemBuilder: (context, index) {
                            final art = _articles[index];
                            final diff = art['difficulty'] ?? 'General';
                            final muscleText = art['muscle_groups'] ?? '';
                            final eqText = art['equipment'] ?? '';
                            final type = art['article_type'] ?? 'GENERAL';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1B1B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.white10, width: 1),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _viewArticleDetails(art['id'].toString()),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              art['title'] ?? '',
                                              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getDifficultyColor(diff).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              diff.toUpperCase(),
                                              style: TextStyle(
                                                color: _getDifficultyColor(diff),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        art['summary'] ?? '',
                                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                if (muscleText.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amberAccent.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      muscleText.split(',').first.trim().toUpperCase(),
                                                      style: const TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                if (eqText.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueAccent.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      eqText.split(',').first.trim().toUpperCase(),
                                                      style: const TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white10,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    type.toString().toUpperCase(),
                                                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (type == 'EXERCISE')
                                            IconButton(
                                              icon: const Icon(Icons.swap_horiz, color: AppColors.primaryFixed),
                                              tooltip: 'Find Swaps',
                                              onPressed: () => _findAlternatives(art['title'] ?? ''),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
