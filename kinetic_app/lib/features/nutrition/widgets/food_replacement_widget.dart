import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../providers/nutrition_providers.dart';

class FoodReplacementWidget extends ConsumerStatefulWidget {
  const FoodReplacementWidget({super.key});

  @override
  ConsumerState<FoodReplacementWidget> createState() => _FoodReplacementWidgetState();
}

class _FoodReplacementWidgetState extends ConsumerState<FoodReplacementWidget> {
  final TextEditingController _foodController = TextEditingController();
  String _reason = 'Budget'; // Budget / Allergy / Preference / Availability
  bool _searching = false;
  List<dynamic>? _results;
  String? _searchedFood;
  int _activePageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _foodController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _searchAlternatives() async {
    final original = _foodController.text.trim();
    if (original.isEmpty) return;
    
    setState(() {
      _searching = true;
      _results = null;
      _searchedFood = original;
      _activePageIndex = 0;
    });

    final profile = ref.read(nutritionProfileProvider).profile;
    final pref = profile?['food_preference'] ?? 'veg';
    final goal = profile?['goal'] ?? 'maintenance';

    try {
      final client = ref.read(apiClientProvider);
      final res = await client.getFoodReplacement({
        'original_food': original,
        'reason': _reason.toLowerCase(),
        'preference': pref,
        'goal': goal,
      });
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() {
          _results = body['data'];
        });
      }
    } catch (_) {}

    setState(() => _searching = false);
  }

  Color _getBadgeColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title handles drag bar indicators
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.swap_horiz, color: AppColors.primaryFixed, size: 24),
            SizedBox(width: 8),
            Text(
              'SWAP FINDER',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Form Fields
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _foodController,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter food name...',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                  fillColor: const Color(0xFF201F1F),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _reason,
                dropdownColor: const Color(0xFF201F1F),
                decoration: InputDecoration(
                  fillColor: const Color(0xFF201F1F),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _reason = v);
                },
                items: ['Budget', 'Allergy', 'Preference', 'Availability'].map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(color: AppColors.white, fontSize: 13)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _searchAlternatives,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryFixed,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Find Healthy Swaps', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),

        // Search States
        if (_searching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryFixed)),
          )
        else if (_results != null && _results!.isNotEmpty)
          Expanded(
            child: Column(
              children: [
                _buildVisualSwapsChain(),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _results!.length,
                    onPageChanged: (idx) => setState(() => _activePageIndex = idx),
                    itemBuilder: (context, index) {
                      final item = _results![index];
                      return _buildReplacementCard(item);
                    },
                  ),
                ),
              ],
            ),
          )
        else if (_results != null && _results!.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text('No suitable alternatives found. Try another term!', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
          ),
      ],
    );
  }

  Widget _buildVisualSwapsChain() {
    final activeSwapName = _results != null ? _results![_activePageIndex]['food'] : 'Swap';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChainStep(_searchedFood ?? 'Original', true),
            const Icon(Icons.arrow_forward, color: AppColors.primaryFixed, size: 16),
            ...List.generate(_results!.length, (idx) {
              final stepName = _results![idx]['food'];
              final isCurrent = idx == _activePageIndex;
              return Row(
                children: [
                  _buildChainStep(stepName, isCurrent),
                  if (idx < _results!.length - 1)
                    const Icon(Icons.arrow_forward, color: AppColors.white10, size: 16),
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildChainStep(String name, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryFixed.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.primaryFixed : AppColors.white10,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: isActive ? AppColors.white : AppColors.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildReplacementCard(dynamic item) {
    final score = item['similarity_score'] ?? 8;
    final qty = item['quantity_per_100g_equivalent'] ?? '100g';
    final notes = item['notes'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['food'],
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBadgeColor(score).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getBadgeColor(score)),
                ),
                child: Text(
                  'Match: $score/10',
                  style: TextStyle(color: _getBadgeColor(score), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Equivalent Portion: $qty',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildMacrosGrid(item)),
          const SizedBox(height: 12),
          if (notes.isNotEmpty) ...[
            const Divider(color: AppColors.white10),
            const SizedBox(height: 8),
            Text(
              notes,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.4),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMacrosGrid(dynamic item) {
    final c = item['calories'] ?? 0;
    final p = item['protein_g'] ?? 0;
    final cb = item['carbs_g'] ?? 0;
    final f = item['fat_g'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildMacroValueCard('Calories', '$c kcal', const Color(0xFFCAF300)),
        _buildMacroValueCard('Protein', '${p}g', const Color(0xFF4B8EFF)),
        _buildMacroValueCard('Carbs', '${cb}g', Colors.amber),
        _buildMacroValueCard('Fats', '${f}g', const Color(0xFFFFB4AB)),
      ],
    );
  }

  Widget _buildMacroValueCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
