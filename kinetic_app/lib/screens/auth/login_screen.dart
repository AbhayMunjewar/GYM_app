import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final String targetRoute;
  const LoginScreen({super.key, this.targetRoute = '/member/dashboard'});

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
          'We\'ve sent a 4-digit token to your email.',
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
          onPressed: () => context.go(widget.targetRoute), // Navigate to target
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
        Text('Didn\'t receive it? Resend Code (45s)', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryFixed)),
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
