import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(Icons.workspace_premium_rounded, size: 80, color: NothingTheme.accent)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scaleXY(begin: 1, end: 1.1, duration: 2.seconds)
                    .shimmer(duration: 2.seconds),
                
                const SizedBox(height: 32),
                
                Text(
                  'Unlock PRO',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 40, color: Colors.white),
                  textAlign: TextAlign.center,
                ).animate().fade(duration: 500.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 16),
                
                Text(
                  'Get the ultimate study advantage with our premium features.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 48),
                
                _buildFeatureRow(context, Icons.auto_awesome_rounded, 'AI Study Plan Generator'),
                const SizedBox(height: 16),
                _buildFeatureRow(context, Icons.bar_chart_rounded, 'Advanced Analytics'),
                const SizedBox(height: 16),
                _buildFeatureRow(context, Icons.all_inclusive_rounded, 'Unlimited Subjects'),
                const SizedBox(height: 16),
                _buildFeatureRow(context, Icons.notifications_active_rounded, 'Smart Push Notifications'),
                
                const Spacer(),
                
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [NothingTheme.accent, Color(0xFFFF5E62)]),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase flow coming soon!', style: TextStyle(color: colorScheme.onSurface)),
                          backgroundColor: colorScheme.surface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Start 7-Day Free Trial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ).animate().scale(delay: 800.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 16),
                
                Text(
                  'Then \$4.99/month. Cancel anytime.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 1.seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NothingTheme.accent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: NothingTheme.accent, size: 24),
        ),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    ).animate().slideX(begin: 0.1, duration: 400.ms).fade();
  }
}
