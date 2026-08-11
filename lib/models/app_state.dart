import 'package:flutter/material.dart';

class Subject {
  String id;
  String name;
  DateTime examDate;
  List<Topic> topics;

  Subject({
    required this.id,
    required this.name,
    required this.examDate,
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

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  String dashboardTitle = "Finals Overview";
  
  List<Subject> subjects = [
    Subject(
      id: "1",
      name: "Mathematics",
      examDate: DateTime.now().add(const Duration(days: 5)),
      topics: [
        Topic(id: "1", name: "Calculus", isCompleted: true),
        Topic(id: "2", name: "Linear Algebra"),
      ],
    ),
    Subject(
      id: "2",
      name: "Physics",
      examDate: DateTime.now().add(const Duration(days: 2)),
      topics: [
        Topic(id: "3", name: "Thermodynamics"),
      ],
    ),
  ];

  void updateDashboardTitle(String newTitle) {
    dashboardTitle = newTitle;
    notifyListeners();
  }

  void addSubject(String name, DateTime date) {
    subjects.add(Subject(
      id: DateTime.now().toString(),
      name: name,
      examDate: date,
      topics: [],
    ));
    notifyListeners();
  }

  void deleteSubject(String id) {
    subjects.removeWhere((s) => s.id == id);
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
