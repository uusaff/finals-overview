import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../services/ai_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isGenerating = false;

  void _generateInsights(AppState state) async {
    setState(() => _isGenerating = true);
    try {
      final aiService = AiService();
      
      int totalTopics = 0;
      int completedTopics = 0;
      for (var s in state.subjects) {
        totalTopics += s.totalTopics;
        completedTopics += s.completedTopics;
      }

      final upcomingExams = state.exams
          .where((e) => !e.isCompleted && e.date.isAfter(DateTime.now()))
          .map((e) => "${e.type} (in ${e.date.difference(DateTime.now()).inDays} days)")
          .toList();

      final insight = await aiService.generateInsights(
        completedTopics: completedTopics,
        totalTopics: totalTopics,
        upcomingExams: upcomingExams,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('AI Insights'),
              ],
            ),
            content: Text(insight, style: const TextStyle(height: 1.5)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('GOT IT'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate insights: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

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
                        progressColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 16),
                      Text('Overall Preparation', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : () => _generateInsights(state),
                          icon: _isGenerating 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.auto_awesome, color: Colors.black),
                          label: Text(
                            _isGenerating ? 'ANALYZING...' : 'AI INSIGHTS',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      )
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
                        progressColor: subject.progress == 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
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
