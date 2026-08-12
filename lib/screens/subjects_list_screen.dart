import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/app_state.dart';
import '../theme.dart';
import 'subject_screen.dart';

class SubjectsListScreen extends StatelessWidget {
  const SubjectsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.subjects.isEmpty) {
            return const Center(child: Text('No subjects added yet!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24).copyWith(bottom: 100),
            itemCount: state.subjects.length,
            itemBuilder: (context, index) {
              final subject = state.subjects[index];
              final subjectExams = state.exams.where((e) => e.subjectId == subject.id).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => SubjectScreen(subjectId: subject.id),
                        transitionsBuilder: (c, a1, a2, child) => FadeTransition(opacity: a1, child: child),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  subject.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: colorScheme.surface,
                                      title: const Text('Delete Subject?'),
                                      content: Text('Are you sure you want to delete ${subject.name} and all its exams?'),
                                      actions: [
                                        TextButton(
                                          child: Text('CANCEL', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                                          onPressed: () => Navigator.pop(ctx),
                                        ),
                                        TextButton(
                                          child: const Text('DELETE', style: TextStyle(color: NothingTheme.accent)),
                                          onPressed: () {
                                            context.read<AppState>().deleteSubject(subject.id);
                                            Navigator.pop(ctx);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                          if (subject.courseCode.isNotEmpty || subject.instructor.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                [if (subject.courseCode.isNotEmpty) subject.courseCode, if (subject.instructor.isNotEmpty) subject.instructor].join(' • '),
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                            ),
                          
                          LinearPercentIndicator(
                            padding: EdgeInsets.zero,
                            lineHeight: 6.0,
                            animation: true,
                            animationDuration: 1000,
                            percent: subject.progress,
                            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                            progressColor: subject.progress == 1.0 ? Colors.green : NothingTheme.accent,
                            barRadius: const Radius.circular(50),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${subject.completedTopics}/${subject.totalTopics} Topics', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                              Text('${subjectExams.length} Exams', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.2, delay: (100 * index).ms).fade(),
              );
            },
          );
        },
      ),
    );
  }
}
