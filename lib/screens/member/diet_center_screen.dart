// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class DietCenterScreen extends StatelessWidget {
//   const DietCenterScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'DIET CENTER',
//           style: Theme.of(context).textTheme.labelLarge,
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Macro Tracking',
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//             const SizedBox(height: 24),
//             GlassCard(
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildMacroDial(context, 'Protein', '120/180g', 0.6),
//                       _buildMacroDial(context, 'Carbs', '200/300g', 0.66),
//                       _buildMacroDial(context, 'Fats', '50/70g', 0.71),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   const Divider(color: Colors.white24),
//                   const SizedBox(height: 24),
//                   Text(
//                     'AI Suggestion: You are behind on protein today. Consider a whey shake post-workout.',
//                     style: TextStyle(color: AppColors.onSurfaceVariant),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(
//               'Meal Plan',
//               style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
//             ),
//             const SizedBox(height: 16),
//             GlassCard(
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.breakfast_dining, color: AppColors.primary),
//                     title: const Text('Oatmeal & Berries'),
//                     subtitle: const Text('450 kcal'),
//                     trailing: const Icon(Icons.check_circle, color: AppColors.primary),
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.lunch_dining, color: AppColors.secondary),
//                     title: const Text('Grilled Chicken Salad'),
//                     subtitle: const Text('600 kcal'),
//                     trailing: const Icon(Icons.radio_button_unchecked, color: Colors.white54),
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMacroDial(BuildContext context, String label, String value, double progress) {
//     return Column(
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 80,
//               height: 80,
//               child: CircularProgressIndicator(
//                 value: progress,
//                 strokeWidth: 8,
//                 backgroundColor: Colors.white.withOpacity(0.1),
//                 color: AppColors.primary,
//               ),
//             ),
//             Text(
//               '${(progress * 100).toInt()}%',
//               style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//         Text(value, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
//       ],
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIDietApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kOnTertiaryContainer = Color(0xFF636565);

class VelocityAIDietApp extends StatelessWidget {
  const VelocityAIDietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Diet Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.white.withOpacity(0.05),
          inactiveTrackColor: Colors.white.withOpacity(0.05),
          thumbColor: kPrimary,
          trackHeight: 4.0,
          overlayColor: kPrimary.withOpacity(0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
        ),
      ),
      home: const DietCenterScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class DietCenterScreen extends StatefulWidget {
  const DietCenterScreen({super.key});

  @override
  State<DietCenterScreen> createState() => _DietCenterScreenState();
}

class _DietCenterScreenState extends State<DietCenterScreen> {
  // State variables for interactive elements
  double _budgetValue = 120.0;
  String _selectedDiet = 'VEGAN';

  void _updateDiet(String diet) {
    setState(() {
      _selectedDiet = diet;
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
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(24.0, 100.0, 24.0, isDesktop ? 40.0 : 120.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeaderAndGenerator(isDesktop),
                      const SizedBox(height: 48),
                      const DailyMealPlan(),
                      const SizedBox(height: 48),
                      _buildNutritionAndGrocery(isDesktop),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop ? const MobileBottomNav() : null,
    );
  }

  // --- SECTIONS ---

  Widget _buildHeaderAndGenerator(bool isDesktop) {
    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 56, fontWeight: FontWeight.w800, height: 1.1, fontFamily: 'Inter'),
            children: [
              TextSpan(text: 'DIET ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'ENGINE', style: TextStyle(color: kPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'AI-optimized nutrition calibrated to your performance goals and financial parameters. Precision fueling starts here.',
          style: TextStyle(color: kOnSurfaceVariant, fontSize: 18, height: 1.5),
        ),
      ],
    );

    final generatorContent = GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_fix_high, color: kPrimary),
              SizedBox(width: 8),
              Text('GENERATE PLAN', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('WEEKLY BUDGET (USD)', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('\$40', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: _budgetValue,
                  min: 40,
                  max: 400,
                  divisions: 36,
                  onChanged: (val) => setState(() => _budgetValue = val),
                ),
              ),
              const Text('\$400', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Center(
            child: Text('\$${_budgetValue.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _DietToggle(title: 'KETO', icon: Icons.local_dining, isSelected: _selectedDiet == 'KETO', onTap: () => _updateDiet('KETO')),
              _DietToggle(title: 'VEGAN', icon: Icons.eco, isSelected: _selectedDiet == 'VEGAN', onTap: () => _updateDiet('VEGAN')),
              _DietToggle(title: 'PALEO', icon: Icons.restaurant, isSelected: _selectedDiet == 'PALEO', onTap: () => _updateDiet('PALEO')),
              _DietToggle(title: 'HIGH PROTEIN', icon: Icons.speed, isSelected: _selectedDiet == 'HIGH PROTEIN', onTap: () => _updateDiet('HIGH PROTEIN')),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('RECALIBRATE AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              onPressed: () {},
            ),
          )
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 8, child: headerContent),
          const SizedBox(width: 24),
          Expanded(flex: 4, child: generatorContent),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerContent,
        const SizedBox(height: 32),
        generatorContent,
      ],
    );
  }

  Widget _buildNutritionAndGrocery(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 5, child: MacroPrecisionCard()),
          SizedBox(width: 24),
          Expanded(flex: 7, child: GroceryListCard()),
        ],
      );
    }
    return Column(
      children: const [
        MacroPrecisionCard(),
        SizedBox(height: 24),
        GroceryListCard(),
      ],
    );
  }
}

// --- WIDGETS: COMPONENTS ---

class _DietToggle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietToggle({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.black : kOnSurfaceVariant, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : kOnSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyMealPlan extends StatelessWidget {
  const DailyMealPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("TODAY'S FUEL", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            Row(
              children: [
                _NavButton(icon: Icons.chevron_left, onTap: () {}),
                const SizedBox(width: 8),
                _NavButton(icon: Icons.chevron_right, onTap: () {}),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 768;
            final meals = [
              const MealCard(
                type: 'Breakfast',
                title: 'Avocado & Vitality Egg Toast',
                price: '\$4.50 EST.',
                cals: '420 kcal',
                protein: '24g Protein',
                fats: '18g Fats',
                imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBReF1dgFyrwgLSQ0p-uGG-2m4-7si1u_ZO_l19Tz-mnQRIoLy6VT1lEMqnQcd-xOwzyYnyAx3Z3aPr8umyNZI5LbyWq7MfC51wDAYR2kM17o2dwty_G9w8kH1LqJ1B9ZXWo_M7Ij_CsIk5_pdB-SgdtMUabMpby97CmmbISE2AzZzj1XKnp_3bFwySc80IyQifwTKRhyJXN3RRAtH8UU5G8LNeybWvW-LK2cF7_3gseAbIKvPnoFpKYQmn83jgFd-UvYhDY8nUK4',
              ),
              const MealCard(
                type: 'Lunch',
                title: 'Pacific Salmon & Quinoa Power',
                price: '\$6.20 EST.',
                cals: '580 kcal',
                protein: '45g Protein',
                fats: '12g Fats',
                imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCAoC6_oGKbokbOCAGAjii0F88mb4HL_P1e-_kwJWlUoUHTeq1nKfhTvJ7zGRCjvFr1kd2DAVvgLt--CNFwMlfGqFjmqU3ndm36CrmDy5-6iWW_uMVKdH6-ch76SgJnWFaCHqP_ROMGb3lmiNzbzjygbP1RRHW0XVIebYjMjEOi3Pp3-q5Qw9PvIHDa2zFliUP41NxuAGowcQ5r6B-zuYgJigupfc-PfhFh6vTTnlr6vzZDoZoSzKR8D4CKaNyD6vUP3z4AzxtAmPs',
              ),
              const MealCard(
                type: 'Dinner',
                title: 'Grass-Fed Beef & Iron Greens',
                price: '\$8.90 EST.',
                cals: '710 kcal',
                protein: '52g Protein',
                fats: '28g Fats',
                imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBEk1yJJIl7pJMZknGegBdfVjp-h5JdnlJ9rVIfoc-ZaJGzcrfaFGgi_m91dAOePXUFfoahZj6-mGHvn7KCxoOc1Awq5wLYnL1wxMHhHlmNZibxGXbE8YRA512R8-PUNPkn1Rxv7Q-tcJdbpJgDtC6vFZKoD1hrwAJmxiVDSOC-ZBvVYhmrf2VLcuuNmphKA-g0kBnSvc763bc78Vs02cIybAwuIWiZ2z0W4FveJdp06efhvafJIZZd-6YwHKGfP_27Ew8jOQyT8EI',
              ),
            ];

            if (isDesktop) {
              return Row(
                children: meals.map((m) => Expanded(
                  child: Padding(padding: EdgeInsets.only(right: m == meals.last ? 0 : 24), child: m),
                )).toList(),
              );
            }
            return Column(
              children: meals.map((m) => Padding(padding: const EdgeInsets.only(bottom: 24), child: m)).toList(),
            );
          },
        )
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String type;
  final String title;
  final String price;
  final String cals;
  final String protein;
  final String fats;
  final String imgUrl;

  const MealCard({
    super.key,
    required this.type,
    required this.title,
    required this.price,
    required this.cals,
    required this.protein,
    required this.fats,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imgUrl, fit: BoxFit.cover),
                Positioned(
                  top: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(price, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.toUpperCase(), style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cals, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                    Text(protein, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                    Text(fats, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MacroPrecisionCard extends StatelessWidget {
  const MacroPrecisionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MACRO PRECISION', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 192,
              height: 192,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        colors: [kSecondary, kPrimary],
                        stops: [0.0, 1.0],
                      ).createShader(rect);
                    },
                    child: const CircularProgressIndicator(
                      value: 0.75, // Approximating visual
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('2,150', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1)),
                      SizedBox(height: 8),
                      Text('KCAL REMAINING', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _ProgressBar(title: 'PROTEIN (180g)', target: '75% TARGET', value: 0.75, color: kPrimary),
          const SizedBox(height: 16),
          _ProgressBar(title: 'CARBS (220g)', target: '42% TARGET', value: 0.42, color: kSecondary),
          const SizedBox(height: 16),
          _ProgressBar(title: 'FATS (65g)', target: '60% TARGET', value: 0.60, color: kOnTertiaryContainer),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String title;
  final String target;
  final double value;
  final Color color;

  const _ProgressBar({required this.title, required this.target, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(target, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.white.withOpacity(0.05),
          valueColor: AlwaysStoppedAnimation(color),
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }
}

class GroceryListCard extends StatelessWidget {
  const GroceryListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('OPTIMIZED GROCERY LIST', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (!isMobile)
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Icon(Icons.shopping_cart, color: kPrimary, size: 16),
                      SizedBox(width: 4),
                      Text('EXPORT TO CART', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () {},
              child: Row(
                children: const [
                  Icon(Icons.shopping_cart, color: kPrimary, size: 16),
                  SizedBox(width: 4),
                  Text('EXPORT TO CART', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CategoryList(
                  title: 'PROTEINS',
                  items: const [
                    {'name': 'Lean Ground Beef (2lb)', 'price': '\$14.00'},
                    {'name': 'Greek Yogurt (32oz)', 'price': '\$5.50'},
                    {'name': 'Wild Salmon (1lb)', 'price': '\$12.00'},
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CategoryList(
                  title: 'PRODUCE',
                  items: const [
                    {'name': 'Organic Spinach (16oz)', 'price': '\$3.50'},
                    {'name': 'Avocados (3ct)', 'price': '\$4.00'},
                    {'name': 'Sweet Potatoes (2lb)', 'price': '\$2.80'},
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('ESTIMATED WEEKLY COST', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('\$118.40', style: TextStyle(color: kPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('UNDER BUDGET', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('-\$1.60', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const _CategoryList({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(item['name']!, style: const TextStyle(color: Colors.white, fontSize: 14))),
                Text(item['price']!, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

// --- WIDGETS: APP BAR & NAV ---

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
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: kPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2A2A2A),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.7),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_circle, color: kPrimary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Level 42 Athlete', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training', isActive: true),
                _NavTile(icon: Icons.analytics, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
                _NavTile(icon: Icons.military_tech, title: 'Rewards'),
                _NavTile(icon: Icons.settings, title: 'Settings'),
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
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
        border: isActive ? const Border(right: BorderSide(color: kPrimary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts', isActive: true),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
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
        Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontSize: 12)),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}

// --- UTILITY WIDGET ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}