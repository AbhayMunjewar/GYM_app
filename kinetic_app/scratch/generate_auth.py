import os

login_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isOtp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'VELOCITY AI',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: AppColors.primaryFixed,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: AppColors.primaryFixed),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryFixed.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(color: AppColors.secondaryContainer.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isOtp ? _buildOtpSection() : _buildFormSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isLogin ? 'Push Beyond.' : 'Join the Elite.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white),
        ),
        const SizedBox(height: 8),
        Text(
          isLogin ? 'Access your high-performance lab.' : 'Initialize your athletic data engine.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        
        // Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1B1B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isLogin = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isLogin ? AppColors.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'LOGIN',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isLogin ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isLogin = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isLogin ? AppColors.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SIGNUP',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: !isLogin ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Form
        Text('WORK EMAIL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'alex@velocity.ai',
            filled: true,
            fillColor: const Color(0xFF201F1F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PASSWORD', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
            if (isLogin)
              GestureDetector(
                onTap: () => context.push('/auth/forgot-password'),
                child: Text('FORGOT?', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primaryFixed)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: const Color(0xFF201F1F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: () {
            if (isLogin) {
              setState(() => isOtp = true);
            } else {
              context.push('/auth/onboarding');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryFixed,
            foregroundColor: AppColors.onPrimaryFixed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.white10)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR KINETIC SYNC', style: TextStyle(color: Color(0xFF444932), fontSize: 12))),
            Expanded(child: Container(height: 1, color: AppColors.white10)),
          ],
        ),
        const SizedBox(height: 32),
        
        Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Text('APPLE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Text('GOOGLE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.verified_user, color: AppColors.primaryFixed, size: 64),
        const SizedBox(height: 24),
        Text(
          'Verify Performance',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'We\\'ve sent a 4-digit token to your email.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text('0', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: AppColors.primaryFixed)),
          )),
        ),
        
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go('/'), // Back to dashboard (for now landing page)
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryFixed,
            foregroundColor: AppColors.onPrimaryFixed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('VERIFY & LAUNCH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(width: 8),
              Icon(Icons.rocket_launch),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Didn\\'t receive it? Resend Code (45s)', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryFixed)),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => setState(() => isOtp = false),
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          label: const Text('CHANGE EMAIL', style: TextStyle(color: AppColors.onSurfaceVariant)),
        )
      ],
    );
  }
}
"""

forgot_password_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isSent = false;

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
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isSent ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.lock_reset, color: AppColors.primaryFixed, size: 32),
        ),
        const SizedBox(height: 24),
        Text('Reset Access', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('Enter your work email to receive a recovery link.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        
        Text('WORK EMAIL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'alex@velocity.ai',
            filled: true,
            fillColor: const Color(0xFF201F1F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: () => setState(() => isSent = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryFixed,
            foregroundColor: AppColors.onPrimaryFixed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('SEND RESET LINK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.check_circle, color: AppColors.secondaryContainer, size: 32),
        ),
        const SizedBox(height: 24),
        Text('Link Sent', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('Check your email for the recovery link to regain access.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        
        OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.white20),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('BACK TO LOGIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ],
    );
  }
}
"""

onboarding_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: step > 1 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => setState(() => step--))
          : IconButton(icon: const Icon(Icons.close, color: AppColors.white), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              Row(
                children: [
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step >= 1 ? AppColors.primaryFixed : AppColors.white10, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step >= 2 ? AppColors.primaryFixed : AppColors.white10, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step >= 3 ? AppColors.primaryFixed : AppColors.white10, borderRadius: BorderRadius.circular(2)))),
                ],
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: step == 1 ? _buildStep1() : (step == 2 ? _buildStep2() : _buildStep3()),
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (step < 3) {
                    setState(() => step++);
                  } else {
                    context.go('/');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(step < 3 ? 'NEXT STEP' : 'COMPLETE PROFILE', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Data', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('Required for baseline calculations.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        Text('AGE', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
        const SizedBox(height: 8),
        TextField(decoration: InputDecoration(hintText: '28', filled: true, fillColor: const Color(0xFF201F1F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEIGHT (KG)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
                  const SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: '82', filled: true, fillColor: const Color(0xFF201F1F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEIGHT (CM)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
                  const SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: '185', filled: true, fillColor: const Color(0xFF201F1F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary Goal', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('What are we optimizing for?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        
        _GoalCard(title: 'HYPERTROPHY', desc: 'Maximized muscle gain', icon: Icons.fitness_center, isSelected: true),
        const SizedBox(height: 16),
        _GoalCard(title: 'ENDURANCE', desc: 'Aerobic capacity & stamina', icon: Icons.directions_run, isSelected: false),
        const SizedBox(height: 16),
        _GoalCard(title: 'STRENGTH', desc: 'Maximal force production', icon: Icons.line_weight, isSelected: false),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Experience', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('Calibrating AI logic models.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        
        _GoalCard(title: 'NOVICE', desc: '< 1 year of consistent training', icon: Icons.trending_up, isSelected: false),
        const SizedBox(height: 16),
        _GoalCard(title: 'INTERMEDIATE', desc: '1-3 years of programming', icon: Icons.bolt, isSelected: true),
        const SizedBox(height: 16),
        _GoalCard(title: 'ELITE', desc: '3+ years, competitive', icon: Icons.military_tech, isSelected: false),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool isSelected;

  const _GoalCard({required this.title, required this.desc, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryFixed.withValues(alpha: 0.1) : const Color(0xFF201F1F),
        border: Border.all(color: isSelected ? AppColors.primaryFixed : Colors.transparent),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryFixed : AppColors.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isSelected ? AppColors.primaryFixed : AppColors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryFixed),
        ],
      ),
    );
  }
}
"""

with open('d:/GYM/kinetic_app/lib/screens/auth/login_screen.dart', 'w', encoding='utf-8') as f:
    f.write(login_dart)

with open('d:/GYM/kinetic_app/lib/screens/auth/forgot_password_screen.dart', 'w', encoding='utf-8') as f:
    f.write(forgot_password_dart)

with open('d:/GYM/kinetic_app/lib/screens/auth/onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(onboarding_dart)
print("Created auth screens")
