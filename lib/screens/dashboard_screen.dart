import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/app_state.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AppState>(
      builder: (context, state, child) {
        // Calculations
        final exams = state.exams.toList()..sort((a, b) => a.date.compareTo(b.date));
        final upcomingExams = exams.where((e) => !e.isCompleted && e.date.isAfter(_now.subtract(const Duration(days: 1)))).toList();
        final completedExams = exams.where((e) => e.isCompleted).length;
        final totalExams = exams.length;
        final remainingExams = totalExams - completedExams;
        
        Exam? nextExam = upcomingExams.isNotEmpty ? upcomingExams.first : null;
        int daysUntilNext = nextExam != null ? nextExam.date.difference(_now).inDays : 0;
        
        final todaysExams = upcomingExams.where((e) {
          return e.date.year == _now.year && e.date.month == _now.month && e.date.day == _now.day;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(state.dashboardTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Next Exam Countdown Widget
              if (nextExam != null)
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NEXT EXAM', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(
                          state.subjects.firstWhere((s) => s.id == nextExam.subjectId, orElse: () => Subject(id: '', name: 'Unknown', topics: [])).name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(nextExam.type, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildCountdownItem('${daysUntilNext.clamp(0, 999)}', 'Days'),
                            const Text(' : ', style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
                            _buildCountdownItem('${(nextExam.date.difference(_now).inHours % 24).clamp(0, 24)}', 'Hours'),
                            const Text(' : ', style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
                            _buildCountdownItem('${(nextExam.date.difference(_now).inMinutes % 60).clamp(0, 60)}', 'Mins'),
                          ],
                        )
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.2).fade(),

              const SizedBox(height: 24),
              
              // Quick Stats
              Text('OVERVIEW', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total', '$totalExams', colorScheme)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Completed', '$completedExams', colorScheme)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Remaining', '$remainingExams', colorScheme)),
                ],
              ).animate().slideY(begin: 0.2, delay: 100.ms).fade(),
              
              const SizedBox(height: 24),
              
              // Overall Progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 8.0,
                        animation: true,
                        percent: totalExams == 0 ? 0 : completedExams / totalExams,
                        center: Text(
                          "${totalExams == 0 ? 0 : ((completedExams / totalExams) * 100).toInt()}%",
                          style: NothingTheme.metricsStyle(isDark).copyWith(fontWeight: FontWeight.bold),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Finals Progress', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Keep pushing!',
                              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              // Upcoming Exams List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('UPCOMING EXAMS', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold, letterSpacing: 2)),
                  TextButton(onPressed: () {}, child: Text('See All', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                ],
              ),
              
              if (upcomingExams.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No upcoming exams!', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                  ),
                ),

              ...upcomingExams.take(3).map((exam) {
                final subject = state.subjects.firstWhere((s) => s.id == exam.subjectId, orElse: () => Subject(id: '', name: 'Unknown', topics: []));
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateFormat('MMM').format(exam.date).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                          Text(DateFormat('dd').format(exam.date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text('${exam.startTime.format(context)} - ${exam.endTime.format(context)}', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ).animate().slideY(begin: 0.2, delay: 300.ms).fade();
              }),
              
              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()])),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}
