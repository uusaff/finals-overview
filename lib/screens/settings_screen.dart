import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../services/coupon_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _isLoadingCoupon = false;

  final List<Color> _navColors = [
    // Free Colors (First 4)
    const Color(0xFFE51D2A), // Red
    const Color(0xFF1D8EE5), // Blue
    const Color(0xFF1DE559), // Green
    const Color(0xFFE5B01D), // Yellow
    // Pro Colors (Next 11)
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
    const Color(0xFF009688), // Teal
    const Color(0xFFE91E63), // Pink
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFFFFFFF), // White
  ];

  final List<Color> _bgColors = [
    // Free Colors (First 4)
    const Color(0xFF0A0A0A), // Black
    const Color(0xFF121212), // Dark Gray
    const Color(0xFF1C1C1E), // Apple Dark
    const Color(0xFF0F172A), // Slate
    // Pro Colors (Next 16)
    const Color(0xFF171923), // Gray 900
    const Color(0xFF2D3748), // Gray 800
    const Color(0xFF1A202C), // Gray 800 Dark
    const Color(0xFF2C5282), // Blue 800
    const Color(0xFF2A4365), // Blue 900
    const Color(0xFF22543D), // Green 800
    const Color(0xFF1C4532), // Green 900
    const Color(0xFF742A2A), // Red 800
    const Color(0xFF63171B), // Red 900
    const Color(0xFF553C9A), // Purple 800
    const Color(0xFF44337A), // Purple 900
    const Color(0xFF7B341E), // Orange 800
    const Color(0xFF652B19), // Orange 900
    const Color(0xFF234E52), // Teal 800
    const Color(0xFF1D4044), // Teal 900
    const Color(0xFF285E61), // Teal 700
  ];

  Future<void> _verifyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoadingCoupon = true);
    
    final isValid = await CouponService().verifyCoupon(code);
    
    if (mounted) {
      setState(() => _isLoadingCoupon = false);
      if (isValid) {
        context.read<AppState>().setProStatus(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pro unlocked! Thank you.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coupon code.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _selectNavColor(Color color, bool isProColor) {
    final appState = context.read<AppState>();
    if (isProColor && !appState.isPro) {
      _showProDialog();
      return;
    }
    appState.updateTheme(accent: color);
  }

  void _selectBgColor(Color color, bool isProColor) {
    final appState = context.read<AppState>();
    if (isProColor && !appState.isPro) {
      _showProDialog();
      return;
    }
    appState.updateTheme(background: color);
  }

  void _showProDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pro Feature'),
        content: const Text('This color is available in the Pro version. Unlock it via IAP or by entering a valid coupon code.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pro Banner / Coupon Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appState.isPro 
                  ? [Colors.amber.shade700, Colors.orange.shade900]
                  : [colorScheme.surface, colorScheme.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: appState.isPro ? Colors.transparent : colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(appState.isPro ? Icons.star_rounded : Icons.lock_outline_rounded, 
                      color: appState.isPro ? Colors.white : colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      appState.isPro ? 'Finals Tracker PRO' : 'Unlock Pro (\$5 Lifetime)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: appState.isPro ? Colors.white : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!appState.isPro) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Coupon Code',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoadingCoupon ? null : _verifyCoupon,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: _isLoadingCoupon 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Apply'),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ).animate().fade().slideY(begin: 0.1),

          const SizedBox(height: 32),
          Text('Theme Customization', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Nav Colors
          Text('Accent Colors', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _navColors.length,
              itemBuilder: (context, index) {
                final color = _navColors[index];
                final isProColor = index >= 4;
                final isSelected = appState.accentColor.value == color.value;
                
                return _buildColorSwatch(
                  color: color, 
                  isProColor: isProColor, 
                  isProActive: appState.isPro, 
                  isSelected: isSelected, 
                  onTap: () => _selectNavColor(color, isProColor)
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Background Colors
          Text('Background Colors', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _bgColors.length,
              itemBuilder: (context, index) {
                final color = _bgColors[index];
                final isProColor = index >= 4;
                final isSelected = (appState.customBackgroundColor?.value ?? (isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5)).value) == color.value;
                
                return _buildColorSwatch(
                  color: color, 
                  isProColor: isProColor, 
                  isProActive: appState.isPro, 
                  isSelected: isSelected, 
                  onTap: () => _selectBgColor(color, isProColor)
                );
              },
            ),
          ),

          const SizedBox(height: 32),
          Text('App Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: colorScheme.primary),
            title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                context.read<AppState>().toggleTheme();
              },
              activeColor: colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 48),

          // Auth / Signout
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()), 
                  (route) => false
                );
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch({
    required Color color,
    required bool isProColor,
    required bool isProActive,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final showLock = isProColor && !isProActive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected 
              ? Border.all(color: Colors.white, width: 3) 
              : Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)
          ] : [],
        ),
        child: showLock 
            ? Icon(Icons.lock_rounded, color: color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white54, size: 20)
            : (isSelected ? Icon(Icons.check_rounded, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null),
      ),
    );
  }
}
