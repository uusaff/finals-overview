import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme.dart';
import 'subject_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _isEditingTitle = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: context.read<AppState>().dashboardTitle);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _submitTitle() {
    context.read<AppState>().updateDashboardTitle(_titleController.text);
    setState(() => _isEditingTitle = false);
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NothingTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Subject', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setModalState) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Exam Date', style: TextStyle(color: NothingTheme.textMuted)),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: TextStyle(color: NothingTheme.textPrimary),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: NothingTheme.accent),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: NothingTheme.accent,
                              surface: NothingTheme.surface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<AppState>().addSubject(nameController.text, selectedDate);
                    Navigator.pop(context);
                  }
                },
                child: const Text('ADD SUBJECT'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Color _getUrgencyColor(int daysLeft) {
    if (daysLeft > 7) return Colors.cyan;
    if (daysLeft >= 4) return Colors.amber;
    if (daysLeft >= 1) return Colors.orange;
    return NothingTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        backgroundColor: NothingTheme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: NothingTheme.background.withValues(alpha: 0.8),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/grid.png'), // Will add a subtle grid later or use CSS-like pattern
                    opacity: 0.05,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Clock Widget
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm:ss').format(_now),
                          style: NothingTheme.metricsStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEE, MMM dd').format(_now),
                          style: NothingTheme.metricsStyle.copyWith(fontSize: 16, color: NothingTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _isEditingTitle
                          ? TextField(
                              controller: _titleController,
                              style: Theme.of(context).textTheme.titleLarge,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onSubmitted: (_) => _submitTitle(),
                            )
                          : GestureDetector(
                              onDoubleTap: () => setState(() => _isEditingTitle = true),
                              child: Text(
                                context.watch<AppState>().dashboardTitle,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
                              ),
                            ),
                    ),
                    if (!_isEditingTitle)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: NothingTheme.textMuted),
                        onPressed: () => setState(() => _isEditingTitle = true),
                      ),
                    if (_isEditingTitle)
                      IconButton(
                        icon: const Icon(Icons.check, color: NothingTheme.accent),
                        onPressed: _submitTitle,
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Global Progress
          SliverToBoxAdapter(
            child: Consumer<AppState>(
              builder: (context, state, child) {
                int totalCompleted = state.subjects.fold(0, (sum, s) => sum + s.completedTopics);
                int totalTopics = state.subjects.fold(0, (sum, s) => sum + s.totalTopics);
                double globalProgress = totalTopics == 0 ? 0 : totalCompleted / totalTopics;

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 8.0,
                            animation: true,
                            percent: globalProgress,
                            center: Text(
                              "${(globalProgress * 100).toInt()}%",
                              style: NothingTheme.metricsStyle.copyWith(fontWeight: FontWeight.bold),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: NothingTheme.accent,
                            backgroundColor: NothingTheme.border,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Mastery', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 4),
                                Text(
                                  '$totalCompleted of $totalTopics topics completed',
                                  style: const TextStyle(color: NothingTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Subjects List
          Consumer<AppState>(
            builder: (context, state, child) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subject = state.subjects[index];
                      final daysLeft = subject.examDate.difference(_now).inDays;
                      final urgencyColor = _getUrgencyColor(daysLeft);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubjectScreen(subjectId: subject.id),
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
                                      Text(subject.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: NothingTheme.textMuted),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: NothingTheme.surface,
                                              title: const Text('Delete Subject?'),
                                              content: Text('Are you sure you want to delete ${subject.name}?'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('CANCEL', style: TextStyle(color: NothingTheme.textMuted)),
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
                                  const SizedBox(height: 16),
                                  // Urgency timeline
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, size: 16, color: urgencyColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${daysLeft < 0 ? 0 : daysLeft} days left',
                                        style: NothingTheme.metricsStyle.copyWith(color: urgencyColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearPercentIndicator(
                                    padding: EdgeInsets.zero,
                                    lineHeight: 6.0,
                                    percent: (30 - (daysLeft.clamp(0, 30))) / 30.0, // Visual representation of approaching date
                                    backgroundColor: NothingTheme.border,
                                    progressColor: urgencyColor,
                                    barRadius: const Radius.circular(50),
                                  ),
                                  const SizedBox(height: 16),
                                  // Subject Progress
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${subject.completedTopics}/${subject.totalTopics} Topics', style: const TextStyle(color: NothingTheme.textMuted)),
                                      Text('${(subject.progress * 100).toInt()}%', style: NothingTheme.metricsStyle),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: state.subjects.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for FAB
        ],
      ),
    );
  }
}
