import 'package:flutter/material.dart';

class Subject {
  String id;
  String name;
  String courseCode;
  String instructor;
  List<Topic> topics;

  Subject({
    required this.id,
    required this.name,
    this.courseCode = '',
    this.instructor = '',
    required this.topics,
  });

  int get completedTopics => topics.where((t) => t.isCompleted).length;
  int get totalTopics => topics.length;
  double get progress => totalTopics == 0 ? 0 : completedTopics / totalTopics;
}

class Topic {
  String id;
  String name;
  bool isCompleted;

  Topic({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });
}

class Exam {
  String id;
  String subjectId;
  String type; // e.g. Midterm, Final
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String room;
  String teacher;
  String notes;
  String priority; // High, Medium, Low
  bool isCompleted;

  Exam({
    required this.id,
    required this.subjectId,
    this.type = 'Final Exam',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.room = '',
    this.teacher = '',
    this.notes = '',
    this.priority = 'Medium',
    this.isCompleted = false,
  });
}

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  String dashboardTitle = "Finals Tracker";
  bool isPro = false;
  Color accentColor = const Color(0xFFE51D2A); // Default Red
  Color? customBackgroundColor;
  String? customBackgroundImage;
  
  void setProStatus(bool status) {
    isPro = status;
    notifyListeners();
  }

  void updateTheme({Color? accent, Color? background, String? bgImage}) {
    if (accent != null) accentColor = accent;
    if (background != null) customBackgroundColor = background;
    if (bgImage != null) customBackgroundImage = bgImage;
    notifyListeners();
  }

  List<Subject> subjects = [
    Subject(
      id: "1",
      name: "Data Structures",
      courseCode: "CS-201",
      instructor: "Dr. Smith",
      topics: [
        Topic(id: "1", name: "Arrays & Linked Lists", isCompleted: true),
        Topic(id: "2", name: "Trees & Graphs"),
      ],
    ),
    Subject(
      id: "2",
      name: "Assembly Language",
      courseCode: "CS-202",
      instructor: "Prof. Johnson",
      topics: [
        Topic(id: "3", name: "Registers & Memory"),
      ],
    ),
  ];

  List<Exam> exams = [];

  AppState() {
    // Generate dummy exams
    exams = [
      Exam(
        id: "1",
        subjectId: "1",
        type: "Final Exam",
        date: DateTime.now().add(const Duration(days: 2)),
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        room: "Room 204",
        teacher: "Dr. Smith",
        priority: "High",
      ),
      Exam(
        id: "2",
        subjectId: "2",
        type: "Midterm",
        date: DateTime.now().add(const Duration(days: 5)),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        room: "Hall A",
        teacher: "Prof. Johnson",
        priority: "Medium",
      ),
    ];
  }

  void updateDashboardTitle(String newTitle) {
    dashboardTitle = newTitle;
    notifyListeners();
  }

  void addSubject(String name, String courseCode, String instructor) {
    subjects.add(Subject(
      id: DateTime.now().toString(),
      name: name,
      courseCode: courseCode,
      instructor: instructor,
      topics: [],
    ));
    notifyListeners();
  }

  void deleteSubject(String id) {
    subjects.removeWhere((s) => s.id == id);
    // Cascade delete exams
    exams.removeWhere((e) => e.subjectId == id);
    notifyListeners();
  }

  void addExam(Exam exam) {
    exams.add(exam);
    notifyListeners();
  }

  void updateExam(Exam updatedExam) {
    final index = exams.indexWhere((e) => e.id == updatedExam.id);
    if (index != -1) {
      exams[index] = updatedExam;
      notifyListeners();
    }
  }

  void deleteExam(String id) {
    exams.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleExamCompletion(String id) {
    final exam = exams.firstWhere((e) => e.id == id);
    exam.isCompleted = !exam.isCompleted;
    notifyListeners();
  }

  void toggleTopic(String subjectId, String topicId) {
    final subject = subjects.firstWhere((s) => s.id == subjectId);
    final topic = subject.topics.firstWhere((t) => t.id == topicId);
    topic.isCompleted = !topic.isCompleted;
    notifyListeners();
  }

  void addTopic(String subjectId, String topicName) {
    final subject = subjects.firstWhere((s) => s.id == subjectId);
    subject.topics.add(Topic(id: DateTime.now().toString(), name: topicName));
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
