import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  String? _selectedSubjectId;
  String _examType = 'Final Exam';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  String _priority = 'Medium';

  final _roomController = TextEditingController();
  final _teacherController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _examTypes = ['Final Exam', 'Midterm', 'Quiz', 'Assignment'];
  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: NothingTheme.accent),
            onPressed: _saveExam,
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.subjects.isEmpty) {
            return const Center(child: Text('Please add a subject first!'));
          }

          if (_selectedSubjectId == null) {
            _selectedSubjectId = state.subjects.first.id;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: state.subjects.map((s) {
                  return DropdownMenuItem(value: s.id, child: Text(s.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubjectId = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _examType,
                decoration: const InputDecoration(labelText: 'Exam Type'),
                items: _examTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) => setState(() => _examType = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_date)),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _date = d);
                },
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Time'),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _startTime);
                        if (t != null) setState(() => _startTime = t);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Time'),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _endTime);
                        if (t != null) setState(() => _endTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room / Location', prefixIcon: Icon(Icons.location_on_rounded)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _teacherController,
                decoration: const InputDecoration(labelText: 'Instructor / Invigilator', prefixIcon: Icon(Icons.person_rounded)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority', prefixIcon: Icon(Icons.flag_rounded)),
                items: _priorities.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes_rounded)),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveExam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: NothingTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SAVE EXAM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveExam() {
    if (_selectedSubjectId == null) return;
    
    final exam = Exam(
      id: DateTime.now().toString(),
      subjectId: _selectedSubjectId!,
      type: _examType,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      room: _roomController.text,
      teacher: _teacherController.text,
      notes: _notesController.text,
      priority: _priority,
    );

    context.read<AppState>().addExam(exam);
    Navigator.pop(context);
  }
}
