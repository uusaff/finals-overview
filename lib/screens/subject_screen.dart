import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/app_state.dart';
import '../theme.dart';

class SubjectScreen extends StatefulWidget {
  final String subjectId;

  const SubjectScreen({super.key, required this.subjectId});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final _topicController = TextEditingController();
  late ConfettiController _confettiController;
  bool _hasConfettiFired = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _topicController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _check100Percent(Subject subject) {
    if (subject.progress == 1.0 && subject.totalTopics > 0 && !_hasConfettiFired) {
      _confettiController.play();
      _hasConfettiFired = true;
    } else if (subject.progress < 1.0) {
      _hasConfettiFired = false;
    }
  }

  void _showAddTopicDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
        ),
        title: const Text('Add Topic'),
        content: TextField(
          controller: _topicController,
          decoration: InputDecoration(
            hintText: 'Enter topic name',
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: Text('CANCEL', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
            onPressed: () {
              _topicController.clear();
              Navigator.pop(ctx);
            },
          ),
          TextButton(
            child: const Text('ADD', style: TextStyle(color: NothingTheme.accent)),
            onPressed: () {
              if (_topicController.text.isNotEmpty) {
                context.read<AppState>().addTopic(widget.subjectId, _topicController.text);
                _topicController.clear();
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ).animate().scale(curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<AppState>(
          builder: (context, state, child) {
            try {
              final subject = state.subjects.firstWhere((s) => s.id == widget.subjectId);
              return Text(subject.name);
            } catch (e) {
              return const Text('Subject'); // fallback if deleted while here
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTopicDialog,
        backgroundColor: NothingTheme.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('ADD TOPIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
      body: Stack(
        children: [
          Consumer<AppState>(
            builder: (context, state, child) {
              Subject subject;
              try {
                subject = state.subjects.firstWhere((s) => s.id == widget.subjectId);
              } catch (e) {
                return const Center(child: Text('Subject not found'));
              }
              
              // Trigger confetti check after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _check100Percent(subject);
              });

              if (subject.topics.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_list_bulleted_add, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.2))
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scaleXY(begin: 1, end: 1.1, duration: 2.seconds),
                      const SizedBox(height: 16),
                      Text(
                        'No topics yet.\nAdd some to your syllabus!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16),
                      ).animate().fade().slideY(begin: 0.5),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: subject.topics.length,
                itemBuilder: (context, index) {
                  final topic = subject.topics[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: topic.isCompleted ? colorScheme.surface.withValues(alpha: 0.5) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: topic.isCompleted ? NothingTheme.accent.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: GestureDetector(
                        onTap: () => context.read<AppState>().toggleTopic(subject.id, topic.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: topic.isCompleted ? NothingTheme.accent : Colors.transparent,
                            border: Border.all(
                              color: topic.isCompleted ? NothingTheme.accent : colorScheme.onSurface.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: topic.isCompleted
                              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                                  .animate().scale(curve: Curves.easeOutBack)
                              : null,
                        ),
                      ),
                      title: Text(
                        topic.name,
                        style: TextStyle(
                          color: topic.isCompleted ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface,
                          decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ).animate(key: ValueKey(topic.id)).slideX(begin: -0.1, delay: (index * 50).ms).fade();
                },
              );
            },
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.1,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
