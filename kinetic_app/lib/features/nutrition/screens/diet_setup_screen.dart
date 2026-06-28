import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../providers/nutrition_providers.dart';

class DietSetupScreen extends ConsumerStatefulWidget {
  const DietSetupScreen({super.key});

  @override
  ConsumerState<DietSetupScreen> createState() => _DietSetupScreenState();
}

class _DietSetupScreenState extends ConsumerState<DietSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form State Values
  String _goal = 'maintenance'; // fat_loss, muscle_gain, maintenance
  final TextEditingController _ageController = TextEditingController(text: '25');
  final TextEditingController _heightController = TextEditingController(text: '170');
  final TextEditingController _weightController = TextEditingController(text: '70');
  String _gender = 'Male';
  String _activityLevel = 'moderately_active'; // sedentary, lightly_active, moderately_active, very_active, athlete
  double _workoutDays = 3;
  final TextEditingController _budgetController = TextEditingController(text: '250');
  
  // Food preference state
  final List<String> _selectedPreferences = ['Vegetarian'];
  final List<String> _preferenceOptions = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian'];
  
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _budgetController.dispose();
    _allergiesController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final String foodPref = _selectedPreferences.isNotEmpty 
        ? _selectedPreferences.first.toLowerCase().replaceAll('-', '_') 
        : 'vegetarian';

    final payload = {
      'goal': _goal,
      'age': int.parse(_ageController.text),
      'height_cm': double.parse(_heightController.text),
      'weight_kg': double.parse(_weightController.text),
      'gender': _gender,
      'activity_level': _activityLevel,
      'workout_days_per_week': _workoutDays.toInt(),
      'budget_inr': int.parse(_budgetController.text),
      'food_preference': foodPref == 'vegetarian' ? 'veg' : (foodPref == 'non_vegetarian' ? 'non-veg' : foodPref),
      'allergies': _allergiesController.text,
      'medical_restrictions': _medicalController.text,
    };

    final success = await ref.read(nutritionProfileProvider.notifier).setupProfile(payload);
    setState(() => _loading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Nutrition Profile Created Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/member/nutrition-dashboard');
    } else {
      final errorMsg = ref.read(nutritionProfileProvider).errorMessage ?? 'Submission failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMsg'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
        title: const Text(
          'AI DIET SETUP',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      _buildGoalSegmentedControl(),
                      const SizedBox(height: 20),
                      _buildNumericFieldsRow(),
                      const SizedBox(height: 20),
                      _buildGenderRadioButtons(),
                      const SizedBox(height: 20),
                      _buildActivityLevelDropdown(),
                      const SizedBox(height: 20),
                      _buildWorkoutDaysSlider(),
                      const SizedBox(height: 20),
                      _buildBudgetField(),
                      const SizedBox(height: 20),
                      _buildFoodPreferencesChips(),
                      const SizedBox(height: 20),
                      _buildTextLimitFields(),
                      const SizedBox(height: 24),
                      _buildDisclaimerCard(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primaryFixed, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tailored AI Nutrition',
                  style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Fill in your details, and our AI sports nutritionist will formulate a daily meal plan designed to fit your goals.',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoalSegmentedControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHAT IS YOUR PRIMARY GOAL?',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildGoalButton('Fat Loss', 'fat_loss', Icons.trending_down),
            const SizedBox(width: 10),
            _buildGoalButton('Maintenance', 'maintenance', Icons.sync),
            const SizedBox(width: 10),
            _buildGoalButton('Muscle Gain', 'muscle_gain', Icons.fitness_center),
          ],
        )
      ],
    );
  }

  Widget _buildGoalButton(String label, String value, IconData icon) {
    final isSelected = _goal == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _goal = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryFixed.withOpacity(0.1) : const Color(0xFF201F1F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryFixed : AppColors.white.withOpacity(0.05),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryFixed : AppColors.onSurfaceVariant, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericFieldsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            label: 'AGE',
            controller: _ageController,
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? 'Invalid age' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            label: 'HEIGHT (CM)',
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            label: 'WEIGHT (KG)',
            controller: _weightController,
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            fillColor: const Color(0xFF201F1F),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryFixed),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderRadio('Male'),
            const SizedBox(width: 16),
            _buildGenderRadio('Female'),
            const SizedBox(width: 16),
            _buildGenderRadio('Other'),
          ],
        )
      ],
    );
  }

  Widget _buildGenderRadio(String label) {
    final isSelected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: _gender,
            activeColor: AppColors.primaryFixed,
            onChanged: (v) {
              if (v != null) setState(() => _gender = v);
            },
          ),
          Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildActivityLevelDropdown() {
    final list = [
      {'val': 'sedentary', 'label': 'Sedentary (Little/No exercise)'},
      {'val': 'lightly_active', 'label': 'Lightly Active (1-3 days/week)'},
      {'val': 'moderately_active', 'label': 'Moderately Active (3-5 days/week)'},
      {'val': 'very_active', 'label': 'Very Active (6-7 days/week)'},
      {'val': 'athlete', 'label': 'Athlete (Twice daily, high load)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVITY LEVEL',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _activityLevel,
          dropdownColor: const Color(0xFF201F1F),
          decoration: InputDecoration(
            fillColor: const Color(0xFF201F1F),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
            ),
          ),
          onChanged: (v) {
            if (v != null) setState(() => _activityLevel = v);
          },
          items: list.map((item) {
            return DropdownMenuItem<String>(
              value: item['val'],
              child: Text(
                item['label']!,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkoutDaysSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'WORKOUT SCHEDULE',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
            ),
            Text(
              '${_workoutDays.toInt()} Days/Week',
              style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 12),
            )
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryFixed,
            inactiveTrackColor: AppColors.white10,
            thumbColor: AppColors.primaryFixed,
            overlayColor: AppColors.primaryFixed.withOpacity(0.2),
          ),
          child: Slider(
            min: 1,
            max: 7,
            divisions: 6,
            value: _workoutDays,
            onChanged: (v) => setState(() => _workoutDays = v),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return _buildTextField(
      label: 'DAILY NUTRITION BUDGET (INR ₹)',
      controller: _budgetController,
      keyboardType: TextInputType.number,
      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
    );
  }

  Widget _buildFoodPreferencesChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FOOD PREFERENCES',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _preferenceOptions.map((pref) {
            final isSelected = _selectedPreferences.contains(pref);
            return FilterChip(
              label: Text(pref),
              selected: isSelected,
              selectedColor: AppColors.primaryFixed.withOpacity(0.2),
              checkmarkColor: AppColors.primaryFixed,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFF201F1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryFixed : AppColors.white.withOpacity(0.05),
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  // Only allow single preference select to simplify backend mapping
                  _selectedPreferences.clear();
                  if (selected) {
                    _selectedPreferences.add(pref);
                  }
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildTextLimitFields() {
    return Column(
      children: [
        _buildTextAreaField(
          label: 'ALLERGIES (Comma Separated)',
          controller: _allergiesController,
          hint: 'e.g. peanuts, dairy, gluten (or leave empty)',
        ),
        const SizedBox(height: 20),
        _buildTextAreaField(
          label: 'MEDICAL RESTRICTIONS',
          controller: _medicalController,
          hint: 'e.g. diabetic, hypertension, thyroid issues',
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            fillColor: const Color(0xFF201F1F),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryFixed),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Disclaimer: Consult your doctor before following any AI-generated diet plan. The generated recipes do not replace medical advice.',
              style: TextStyle(color: Colors.orange, fontSize: 12, height: 1.4),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryFixed,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.onPrimaryFixed, size: 20),
          SizedBox(width: 8),
          Text(
            'GENERATE MY AI DIET',
            style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}
