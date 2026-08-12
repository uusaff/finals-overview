import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Exam> _getExamsForDay(DateTime day, List<Exam> allExams) {
    return allExams.where((exam) {
      return exam.date.year == day.year &&
             exam.date.month == day.month &&
             exam.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final examsForSelectedDay = _getExamsForDay(_selectedDay ?? _focusedDay, state.exams);

          return Column(
            children: [
              TableCalendar<Exam>(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getExamsForDay(day, state.exams),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: colorScheme.onSurface),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                    children: [
                      Text(
                        isSameDay(_selectedDay, DateTime.now()) 
                            ? 'Today\'s Exams' 
                            : DateFormat('EEEE, MMMM d').format(_selectedDay!),
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 16),
                      if (examsForSelectedDay.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'No exams scheduled on this day.',
                              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      ...examsForSelectedDay.map((exam) {
                        final subject = state.subjects.firstWhere((s) => s.id == exam.subjectId, orElse: () => Subject(id: '', name: 'Unknown', topics: []));
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                      const SizedBox(width: 4),
                                      Text('${exam.startTime.format(context)} - ${exam.endTime.format(context)}', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
                                      const SizedBox(width: 16),
                                      Icon(Icons.location_on_rounded, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                      const SizedBox(width: 4),
                                      Text(exam.room.isNotEmpty ? exam.room : 'TBD', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(exam.type, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            trailing: Checkbox(
                              value: exam.isCompleted,
                              onChanged: (_) {
                                context.read<AppState>().toggleExamCompletion(exam.id);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ).animate().slideY(begin: 0.2).fade();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
