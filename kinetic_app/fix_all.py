import os
import glob
import re

folders = [
    r'lib\screens\owner\*.dart',
    r'lib\screens\member\*.dart',
    r'lib\screens\trainer\*.dart'
]

# Files that need wrapper classes added at the end
wrapper_classes = {
    r'lib\screens\member\workout_center_screen.dart': ('WorkoutCenterScreen', 'const WelcomeSection(), const SizedBox(height: 32), const MainDashboardGrid(), const SizedBox(height: 48), const ProgramsHeader(), const SizedBox(height: 24), const ProgramsGrid(), const SizedBox(height: 48), const Text(\'Workout History\', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 24), const HistoryTable()'),
    r'lib\screens\member\diet_center_screen.dart': ('DietCenterScreen', 'const MacroPrecisionCard(), const SizedBox(height: 32), const DailyMealPlan(), const SizedBox(height: 32), const GroceryListCard()'),
    r'lib\screens\member\progress_tracker_screen.dart': ('ProgressTrackerScreen', 'const KpiBentoGrid(), const SizedBox(height: 32), const ChartSection(), const SizedBox(height: 32), const MeasurementsCard(), const SizedBox(height: 32), const ProgressPhotosSection()'),
    r'lib\screens\member\rewards_center_screen.dart': ('RewardsCenterScreen', 'const MarketplaceSection(), const SizedBox(height: 32), const RedemptionHistorySection()'),
    r'lib\screens\member\profile_settings_screen.dart': ('ProfileSettingsScreen', 'const PersonalInfoCard(), const SizedBox(height: 32), const GoalSettingsCard(), const SizedBox(height: 32), const AppPreferencesCard(), const SizedBox(height: 32), const PrivacySecurityCard()')
}

wrapper_template = '''
class {class_name} extends StatelessWidget {{
  const {class_name}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              {components}
            ],
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 ? const MobileBottomNav() : null,
    );
  }}
}}
'''

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # 1. withOpacity -> withValues
    content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)

    # 2. MaterialStateProperty -> WidgetStateProperty
    content = content.replace('MaterialStateProperty', 'WidgetStateProperty')

    # 3. Icons fixes
    content = content.replace('Icons.monitoring', 'Icons.analytics')
    content = content.replace('Icons.exercise', 'Icons.fitness_center')

    # 4. kSecondary -> kSecondaryContainer in member_dashboard
    if 'member_dashboard.dart' in filepath:
        content = content.replace('kSecondary', 'kSecondaryContainer')
        # make sure it is defined
        if 'const Color kSecondaryContainer =' not in content:
            content = content.replace('const Color kPrimary = Color(0xFFCAF300);', 'const Color kPrimary = Color(0xFFCAF300);\nconst Color kSecondaryContainer = Color(0xFF4B8EFF);')

    # 5. Pending dues fix
    if 'billing_payments_screen.dart' in filepath:
        content = content.replace('Pending Dues: \\$420.00', 'Pending Dues: \$420.00')

    # 6. Remove rogue void main
    # Find `void main() { ... runApp( ... ) ... }`
    content = re.sub(r'void main\(\)\s*\{[\s\S]*?runApp\([\s\S]*?\}\s*', '', content)
    
    # 7. Add onTap for _NavTile
    nav_tile_target = '''        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),'''
    nav_tile_replacement = '''        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => navigateByTitle(context, title),
      ),'''
    content = content.replace(nav_tile_target, nav_tile_replacement)

    # 8. Add onTap for _BottomNavIcon
    bottom_nav_target = '''  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['''
    bottom_nav_replacement = '''  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateByTitle(context, title),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['''
    
    if bottom_nav_target in content:
        content = content.replace(bottom_nav_target, bottom_nav_replacement)
        # Also close the GestureDetector safely. _BottomNavIcon build method ends with `],);}` 
        # Actually replacing `],);}` is safe since it's a specific pattern at the end of _BottomNavIcon
        content = re.sub(
            r'if \(isActive\) \.\.\.\[\s*const SizedBox\(height: 4\),\s*Container\(width: 4, height: 4, decoration: const BoxDecoration\(color: kPrimary, shape: BoxShape.circle\)\),\s*\]\s*\],\s*\);\s*\}',
            r'if (isActive) ...[\n          const SizedBox(height: 4),\n          Container(width: 4, height: 4, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),\n        ]\n      ],\n    ),\n  );\n}',
            content
        )

    # Inject nav_utils import if navigateByTitle was added
    if 'navigateByTitle' in content and 'nav_utils.dart' not in content:
        import_stmt = "import '../../utils/nav_utils.dart';"
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)

    # 9. Handle wrappers
    for w_file, (cname, comps) in wrapper_classes.items():
        if os.path.normpath(filepath) == os.path.normpath(w_file):
            if f'class {cname} extends' not in content.replace('// ', ''):
                content += wrapper_template.format(class_name=cname, components=comps)
            elif f'\nclass {cname} extends' not in content:
                # The commented version exists, we just append the active one
                content += wrapper_template.format(class_name=cname, components=comps)

    # 10. Fix AppPreferencesCard error in profile_settings_screen
    if 'profile_settings_screen.dart' in filepath:
        content = content.replace('AppPreferencesCard(pushNotifs: true, darkMode: true, hapticFeedback: true, onPushChanged: (v){}, onDarkChanged: (v){}, onHapticChanged: (v){})', 'const AppPreferencesCard()')
        
        # Add a mock AppPreferencesCard if it doesn't exist
        if 'class AppPreferencesCard extends' not in content:
            content += '''
class AppPreferencesCard extends StatelessWidget {
  const AppPreferencesCard({super.key});
  @override
  Widget build(BuildContext context) {
    return const GlassCard(child: Text('App Preferences', style: TextStyle(color: Colors.white)));
  }
}
'''

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Fixed {filepath}')

for pattern in folders:
    for file in glob.glob(pattern):
        process_file(file)

