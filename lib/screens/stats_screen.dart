import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final totalExams = state.exams.length;
          final completedExams = state.exams.where((e) => e.isCompleted).length;
          final remainingExams = totalExams - completedExams;
          final overallPreparation = state.subjects.isEmpty 
              ? 0.0 
              : state.subjects.map((s) => s.progress).reduce((a, b) => a + b) / state.subjects.length;

          return ListView(
            padding: const EdgeInsets.all(24).copyWith(bottom: 100),
            children: [
              Text('OVERALL PROGRESS', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 12.0,
                        animation: true,
                        percent: overallPreparation,
                        center: Text(
                          "${(overallPreparation * 100).toInt()}%",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: NothingTheme.accent,
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 16),
                      Text('Overall Preparation', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ).animate().scale(curve: Curves.easeOutBack),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Exams Done', '$completedExams', colorScheme)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Remaining', '$remainingExams', colorScheme)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Streak', '🔥 4d', colorScheme)), // Mock streak
                ],
              ).animate().slideY(begin: 0.2, delay: 100.ms).fade(),

              const SizedBox(height: 32),
              Text('SUBJECT-WISE PROGRESS', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              
              if (state.subjects.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No subjects added.'))),

              ...state.subjects.asMap().entries.map((entry) {
                final index = entry.key;
                final subject = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(subject.progress * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 8.0,
                        animation: true,
                        animationDuration: 1000,
                        percent: subject.progress,
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                        progressColor: subject.progress == 1.0 ? Colors.green : NothingTheme.accent,
                        barRadius: const Radius.circular(50),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.2, delay: (200 + (index * 50)).ms).fade();
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}
