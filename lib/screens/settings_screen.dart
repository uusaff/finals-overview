import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_state.dart';
import '../theme.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Analytics'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // PRO Banner
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NothingTheme.accent, Color(0xFFFF5E62)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: NothingTheme.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.crown, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upgrade to PRO', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('Unlock AI Study Plans & Analytics', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.white),
                ],
              ),
            ),
          ).animate().slideX(begin: 0.1, duration: 400.ms).fade(),
          
          const SizedBox(height: 32),
          
          Text('Activity', style: Theme.of(context).textTheme.titleLarge).animate().fade(delay: 100.ms),
          const SizedBox(height: 16),
          
          // Chart
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(days[value.toInt()], style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: [2, 5, 3, 7, 4, 8, 1][i].toDouble(),
                          color: NothingTheme.accent,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    ),
                ],
              ),
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 32),
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge).animate().fade(delay: 300.ms),
          const SizedBox(height: 16),
          
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: Icon(isDark ? LucideIcons.moon : LucideIcons.sun),
                  value: isDark,
                  activeColor: NothingTheme.accent,
                  onChanged: (_) => context.read<AppState>().toggleTheme(),
                ),
                Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                ListTile(
                  title: const Text('Push Notifications'),
                  secondary: const Icon(LucideIcons.bell),
                  trailing: const Icon(LucideIcons.lock, size: 16),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
                  },
                ),
                Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                ListTile(
                  title: const Text('Sign Out'),
                  secondary: const Icon(LucideIcons.logOut),
                  textColor: NothingTheme.accent,
                  iconColor: NothingTheme.accent,
                  onTap: () {
                     Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1, delay: 400.ms).fade(),
        ],
      ),
    );
  }
}
