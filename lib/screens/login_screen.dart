import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;

  // Password strength checks
  bool _hasMinLength = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  void _checkPassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpper = password.contains(RegExp(r'[A-Z]'));
      _hasLower = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUpper && _hasLower && _hasNumber && _hasSpecial;

  void _submit() {
    if (_isSignup && !_isPasswordValid) return;
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields', style: TextStyle(color: NothingTheme.textPrimary)),
          backgroundColor: NothingTheme.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Mock successful login/signup
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : NothingTheme.textMuted,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? NothingTheme.textPrimary : NothingTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isSignup ? 'Create Account' : 'Welcome Back',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Finals Overview',
                style: NothingTheme.metricsStyle.copyWith(color: NothingTheme.accent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: NothingTheme.textMuted),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                onChanged: _isSignup ? _checkPassword : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: NothingTheme.textMuted),
                ),
                obscureText: true,
              ),
              if (_isSignup) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NothingTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NothingTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password Requirements', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      _buildRequirement('At least 8 characters', _hasMinLength),
                      _buildRequirement('One uppercase letter', _hasUpper),
                      _buildRequirement('One lowercase letter', _hasLower),
                      _buildRequirement('One number', _hasNumber),
                      _buildRequirement('One special character', _hasSpecial),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_isSignup && !_isPasswordValid) ? null : _submit,
                child: Text(_isSignup ? 'SIGN UP' : 'LOGIN'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isSignup = !_isSignup),
                child: Text(
                  _isSignup ? 'Already have an account? Login' : "Don't have an account? Sign up",
                  style: const TextStyle(color: NothingTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
