import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String targetRoute;
  const LoginScreen({super.key, this.targetRoute = '/member/dashboard'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isOtp = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  String? _errorMessage;
  bool _localLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  String get _currentRoleString {
    if (widget.targetRoute.contains('/owner')) return 'OWNER';
    if (widget.targetRoute.contains('/trainer')) return 'TRAINER';
    return 'MEMBER';
  }

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
                  onTap: () => setState(() {
                    isLogin = true;
                    _errorMessage = null;
                  }),
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
                  onTap: () => setState(() {
                    isLogin = false;
                    _errorMessage = null;
                  }),
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

        // Error message card
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Form Fields
        if (!isLogin) ...[
          Text('FULL NAME', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
          const SizedBox(height: 8),
          TextField(
            controller: _fullNameController,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Alex Rivera',
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: const Color(0xFF201F1F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text('WORK EMAIL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: AppColors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'alex@velocity.ai',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
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
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: const Color(0xFF201F1F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: _localLoading
              ? null
              : () async {
                  setState(() {
                    _errorMessage = null;
                  });

                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  final fullName = _fullNameController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    setState(() {
                      _errorMessage = 'Email and password are required.';
                    });
                    return;
                  }

                  if (!isLogin && fullName.isEmpty) {
                    setState(() {
                      _errorMessage = 'Full name is required.';
                    });
                    return;
                  }

                  setState(() {
                    _localLoading = true;
                  });

                  if (isLogin) {
                    final err = await authService.login(email, password);
                    setState(() {
                      _localLoading = false;
                    });
                    if (err == null) {
                      if (!mounted) return;
                      // Navigate to role-specific dashboard
                      final role = authService.currentRole;
                      String dashboard;
                      if (role == UserRole.owner) {
                        dashboard = '/owner/dashboard';
                      } else if (role == UserRole.trainer) {
                        dashboard = '/trainer/dashboard';
                      } else {
                        dashboard = '/member/dashboard';
                      }
                      context.go(dashboard);
                    } else {
                      setState(() {
                        _errorMessage = err;
                      });
                    }
                  } else {
                    final err = await authService.register(
                      fullName: fullName,
                      username: email.split('@')[0],
                      email: email,
                      password: password,
                      role: _currentRoleString,
                    );
                    setState(() {
                      _localLoading = false;
                    });
                    if (err == null) {
                      // Auto-login after successful registration
                      final loginErr = await authService.login(email, password);
                      setState(() {
                        _localLoading = false;
                      });
                      if (loginErr == null && mounted) {
                        // Navigate to the correct dashboard based on role
                        final role = authService.currentRole;
                        String dashboard;
                        if (role == UserRole.owner) {
                          dashboard = '/owner/dashboard';
                        } else if (role == UserRole.trainer) {
                          dashboard = '/trainer/dashboard';
                        } else {
                          dashboard = '/member/dashboard';
                        }
                        context.go(dashboard);
                      } else {
                        // Auto-login failed, fall back to login tab
                        setState(() {
                          isLogin = true;
                          _errorMessage = loginErr ?? 'Auto-login failed. Please login manually.';
                          _passwordController.clear();
                        });
                      }
                    } else {
                      setState(() {
                        _errorMessage = err;
                      });
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryFixed,
            foregroundColor: AppColors.onPrimaryFixed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _localLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimaryFixed),
                  ),
                )
              : Row(
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
