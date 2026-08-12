import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;
  bool _isLoading = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Español', 'Français', 'Urdu'];

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

  void _submitEmailPassword() async {
    if (_isSignup && !_isPasswordValid) return;
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      if (_isSignup) {
        await authService.signUpWithEmail(_emailController.text, _passwordController.text);
      } else {
        await authService.signInWithEmail(_emailController.text, _passwordController.text);
      }
      if (!mounted) return;
      _navigateToMain();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Authentication failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
      if (!mounted) return;
      _navigateToMain();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Sign-In failed or canceled')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _submitApple() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apple Sign-In requires a physical iOS device and Developer Account.')));
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isMet ? Colors.green : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              icon: Icon(Icons.language_rounded, color: colorScheme.onSurface),
              items: _languages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.school_rounded, size: 48, color: NothingTheme.accent)
                  .animate()
                  .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(),
              const SizedBox(height: 24),
              Text(
                _isSignup ? 'Create Account' : 'Welcome Back',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Finals Overview',
                style: NothingTheme.metricsStyle(isDark).copyWith(color: NothingTheme.accent, fontSize: 16),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),
              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                keyboardType: TextInputType.emailAddress,
              ).animate().fade(delay: 300.ms).slideX(begin: -0.05, end: 0),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                onChanged: _isSignup ? _checkPassword : null,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_rounded, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                obscureText: true,
              ).animate().fade(delay: 400.ms).slideX(begin: -0.05, end: 0),
              
              if (_isSignup) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password Requirements', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      _buildRequirement('At least 8 characters', _hasMinLength),
                      _buildRequirement('One uppercase letter', _hasUpper),
                      _buildRequirement('One lowercase letter', _hasLower),
                      _buildRequirement('One number', _hasNumber),
                      _buildRequirement('One special character', _hasSpecial),
                    ],
                  ),
                ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
              ],
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isSignup && !_isPasswordValid) || _isLoading ? null : _submitEmailPassword,
                  child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isSignup ? 'SIGN UP' : 'LOGIN', style: const TextStyle(letterSpacing: 1.2)),
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => setState(() => _isSignup = !_isSignup),
                child: Text(
                  _isSignup ? 'Already have an account? Login' : "Don't have an account? Sign up",
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ).animate().fade(delay: 600.ms),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.2))),
                ],
              ),
              const SizedBox(height: 24),
              
              // Social Logins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(Icons.g_mobiledata_rounded, 'Google', _submitGoogle, colorScheme),
                  _buildSocialButton(Icons.apple_rounded, 'Apple', _submitApple, colorScheme),
                ],
              ).animate().fade(delay: 700.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
