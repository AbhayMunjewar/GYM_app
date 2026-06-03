import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/glass_card.dart';
import '../../components/kinetic_button.dart';
import '../../components/kinetic_input.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!_isLogin) ...[
                  const KineticInput(hintText: 'Full Name'),
                  const SizedBox(height: 16),
                ],
                const KineticInput(hintText: 'Email Address'),
                const SizedBox(height: 16),
                const KineticInput(hintText: 'Password', obscureText: true),
                const SizedBox(height: 32),
                KineticButton(
                  text: _isLogin ? 'Login' : 'Sign Up',
                  onPressed: () {
                    if (_isLogin) {
                      context.go('/dashboard');
                    } else {
                      context.push('/onboarding');
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Need an account? Sign Up'
                        : 'Already have an account? Login',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
