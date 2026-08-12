import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme.dart';
import 'subject_screen.dart';
import 'pomodoro_screen.dart';
import 'settings_screen.dart';
import 'focus_mode_screen.dart';
import 'ai_generator_screen.dart';

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
  bool _isFabOpen = false;

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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
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
                  title: Text('Exam Date', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded, color: NothingTheme.accent),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: NothingTheme.accent,
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

  Widget _buildFabMenu(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabOpen) ...[
          _buildFabMenuItem(
            Icons.settings_rounded, 
            'Settings', 
            () {
              setState(() => _isFabOpen = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }, 
            colorScheme
          ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms).fade(),
          const SizedBox(height: 12),
          _buildFabMenuItem(
            Icons.timer_rounded, 
            'Study Timer', 
            () {
              setState(() => _isFabOpen = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroScreen()));
            }, 
            colorScheme
          ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms, delay: 50.ms).fade(),
          const SizedBox(height: 12),
          _buildFabMenuItem(
            Icons.dark_mode_rounded, 
            'Focus Mode (AOD)', 
            () {
              setState(() => _isFabOpen = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusModeScreen()));
            }, 
            colorScheme
          ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms, delay: 100.ms).fade(),
          const SizedBox(height: 12),
          _buildFabMenuItem(
            Icons.auto_awesome_rounded, 
            'AI Generator', 
            () {
              setState(() => _isFabOpen = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiGeneratorScreen()));
            }, 
            colorScheme
          ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms, delay: 150.ms).fade(),
          const SizedBox(height: 12),
          _buildFabMenuItem(
            Icons.add_rounded, 
            'Add Subject', 
            () {
              setState(() => _isFabOpen = false);
              _showAddSubjectDialog();
            }, 
            colorScheme,
            isAccent: true
          ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms, delay: 200.ms).fade(),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
          backgroundColor: _isFabOpen ? colorScheme.surface : NothingTheme.accent,
          foregroundColor: _isFabOpen ? colorScheme.onSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isFabOpen ? colorScheme.onSurface.withValues(alpha: 0.1) : Colors.transparent,
            ),
          ),
          child: Icon(_isFabOpen ? Icons.close_rounded : Icons.menu_rounded),
        ).animate(target: _isFabOpen ? 1 : 0).rotate(begin: 0, end: 0.125),
      ],
    );
  }

  Widget _buildFabMenuItem(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme, {bool isAccent = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Text(label, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: isAccent ? NothingTheme.accent : colorScheme.surface,
          foregroundColor: isAccent ? Colors.white : colorScheme.onSurface,
          elevation: 2,
          child: Icon(icon),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: _buildFabMenu(colorScheme),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('HH:mm:ss').format(_now),
                              style: NothingTheme.metricsStyle(isDark).copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('EEE, MMM dd').format(_now),
                              style: NothingTheme.metricsStyle(isDark).copyWith(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.5)),
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
                                  ).animate().fade(duration: 800.ms).slideX(begin: -0.1),
                                ),
                        ),
                        if (!_isEditingTitle)
                          IconButton(
                            icon: Icon(Icons.edit_rounded, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                            onPressed: () => setState(() => _isEditingTitle = true),
                          ),
                        if (_isEditingTitle)
                          IconButton(
                            icon: const Icon(Icons.check_rounded, color: NothingTheme.accent),
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
                                animationDuration: 1500,
                                percent: globalProgress,
                                center: Text(
                                  "${(globalProgress * 100).toInt()}%",
                                  style: NothingTheme.metricsStyle(isDark).copyWith(fontWeight: FontWeight.bold),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: NothingTheme.accent,
                                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
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
                                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
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
                                          Text(subject.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  backgroundColor: colorScheme.surface,
                                                  title: const Text('Delete Subject?'),
                                                  content: Text('Are you sure you want to delete ${subject.name}?'),
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
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(Icons.timer_outlined, size: 16, color: urgencyColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${daysLeft < 0 ? 0 : daysLeft} days left',
                                            style: NothingTheme.metricsStyle(isDark).copyWith(color: urgencyColor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearPercentIndicator(
                                        padding: EdgeInsets.zero,
                                        lineHeight: 6.0,
                                        animation: true,
                                        animationDuration: 1000,
                                        percent: (30 - (daysLeft.clamp(0, 30))) / 30.0,
                                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                                        progressColor: urgencyColor,
                                        barRadius: const Radius.circular(50),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${subject.completedTopics}/${subject.totalTopics} Topics', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                                          Text('${(subject.progress * 100).toInt()}%', style: NothingTheme.metricsStyle(isDark)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().slideY(begin: 0.2, delay: (200 + (index * 100)).ms).fade(),
                          );
                        },
                        childCount: state.subjects.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          if (_isFabOpen)
            GestureDetector(
              onTap: () => setState(() => _isFabOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ).animate().fade(duration: 200.ms),
            ),
        ],
      ),
    );
  }
}
