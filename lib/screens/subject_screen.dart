import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _showAddTopicDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NothingTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NothingTheme.border, width: 1),
        ),
        title: const Text('Add Topic'),
        content: TextField(
          controller: _topicController,
          decoration: const InputDecoration(hintText: 'Enter topic name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: NothingTheme.textMuted)),
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
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NothingTheme.background,
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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD TOPIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          Subject subject;
          try {
            subject = state.subjects.firstWhere((s) => s.id == widget.subjectId);
          } catch (e) {
            return const Center(child: Text('Subject not found'));
          }

          if (subject.topics.isEmpty) {
            return const Center(
              child: Text(
                'No topics yet.\nAdd some to your syllabus!',
                textAlign: TextAlign.center,
                style: TextStyle(color: NothingTheme.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: subject.topics.length,
            itemBuilder: (context, index) {
              final topic = subject.topics[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: topic.isCompleted ? NothingTheme.surface.withValues(alpha: 0.5) : NothingTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: topic.isCompleted ? NothingTheme.accent.withValues(alpha: 0.3) : NothingTheme.border,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: GestureDetector(
                    onTap: () => context.read<AppState>().toggleTopic(subject.id, topic.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: topic.isCompleted ? NothingTheme.accent : Colors.transparent,
                        border: Border.all(
                          color: topic.isCompleted ? NothingTheme.accent : NothingTheme.textMuted,
                          width: 2,
                        ),
                      ),
                      child: topic.isCompleted
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: Text(
                    topic.name,
                    style: TextStyle(
                      color: topic.isCompleted ? NothingTheme.textMuted : NothingTheme.textPrimary,
                      decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
