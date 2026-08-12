import 'package:flutter/flutter.dart'; // fallback
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class Topic {
  String id;
  String name;
  bool isCompleted;

  Topic({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'courseCode': courseCode,
      'instructor': instructor,
      'topics': topics.map((t) => t.toMap()).toList(),
    };
  }

  factory Subject.fromMap(String id, Map<String, dynamic> map) {
    return Subject(
      id: id,
      name: map['name'] ?? '',
      courseCode: map['courseCode'] ?? '',
      instructor: map['instructor'] ?? '',
      topics: (map['topics'] as List<dynamic>?)
              ?.map((t) => Topic.fromMap(Map<String, dynamic>.from(t)))
              .toList() ??
          [],
    );
  }
}

class Exam {
  String id;
  String subjectId;
  String type;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String room;
  String teacher;
  String notes;
  String priority;
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

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'type': type,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'room': room,
      'teacher': teacher,
      'notes': notes,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory Exam.fromMap(String id, Map<String, dynamic> map) {
    final startParts = (map['startTime'] as String? ?? '0:0').split(':');
    final endParts = (map['endTime'] as String? ?? '0:0').split(':');
    return Exam(
      id: id,
      subjectId: map['subjectId'] ?? '',
      type: map['type'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      startTime: TimeOfDay(
          hour: int.tryParse(startParts[0]) ?? 0,
          minute: int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0),
      endTime: TimeOfDay(
          hour: int.tryParse(endParts[0]) ?? 0,
          minute: int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0),
      room: map['room'] ?? '',
      teacher: map['teacher'] ?? '',
      notes: map['notes'] ?? '',
      priority: map['priority'] ?? 'Medium',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  String dashboardTitle = "Finals Tracker";
  bool isPro = false;
  Color accentColor = const Color(0xFFE51D2A); // Default Red
  Color? customBackgroundColor;
  String? customBackgroundImage;
  
  final DatabaseService _db = DatabaseService();
  StreamSubscription? _subjectsSub;
  StreamSubscription? _examsSub;
  String? _uid;

  List<Subject> subjects = [];
  List<Exam> exams = [];

  AppState() {
    // Listen to auth changes so we know who is logged in
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _uid = user.uid;
        _initStreams();
      } else {
        _uid = null;
        _subjectsSub?.cancel();
        _examsSub?.cancel();
        subjects = [];
        exams = [];
        notifyListeners();
      }
    });
  }

  void _initStreams() {
    if (_uid == null) return;
    _subjectsSub?.cancel();
    _examsSub?.cancel();
    
    _subjectsSub = _db.streamSubjects(_uid!).listen((newSubjects) {
      subjects = newSubjects;
      notifyListeners();
    });
    
    _examsSub = _db.streamExams(_uid!).listen((newExams) {
      exams = newExams;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subjectsSub?.cancel();
    _examsSub?.cancel();
    super.dispose();
  }

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

  void updateDashboardTitle(String newTitle) {
    dashboardTitle = newTitle;
    notifyListeners();
  }

  void addSubject(String name, String courseCode, String instructor) {
    if (_uid == null) return;
    final subject = Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      courseCode: courseCode,
      instructor: instructor,
      topics: [],
    );
    _db.addSubject(_uid!, subject);
  }

  void addGeneratedSubject(String name, List<String> topicNames) {
    if (_uid == null) return;
    final subject = Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      courseCode: '',
      instructor: '',
      topics: topicNames.map((t) => Topic(
        id: DateTime.now().millisecondsSinceEpoch.toString() + t.hashCode.toString(), 
        name: t
      )).toList(),
    );
    _db.addSubject(_uid!, subject);
  }

  void deleteSubject(String id) {
    if (_uid == null) return;
    _db.deleteSubject(_uid!, id);
    // Cascade delete exams
    for (var exam in exams.where((e) => e.subjectId == id)) {
      _db.deleteExam(_uid!, exam.id);
    }
  }

  void addExam(Exam exam) {
    if (_uid == null) return;
    _db.addExam(_uid!, exam);
  }

  void updateExam(Exam updatedExam) {
    if (_uid == null) return;
    _db.updateExam(_uid!, updatedExam);
  }

  void deleteExam(String id) {
    if (_uid == null) return;
    _db.deleteExam(_uid!, id);
  }

  void toggleExamCompletion(String id) {
    if (_uid == null) return;
    final index = exams.indexWhere((e) => e.id == id);
    if (index != -1) {
      final exam = exams[index];
      exam.isCompleted = !exam.isCompleted;
      _db.updateExam(_uid!, exam);
    }
  }

  void toggleTopic(String subjectId, String topicId) {
    if (_uid == null) return;
    final sIndex = subjects.indexWhere((s) => s.id == subjectId);
    if (sIndex != -1) {
      final subject = subjects[sIndex];
      final tIndex = subject.topics.indexWhere((t) => t.id == topicId);
      if (tIndex != -1) {
        subject.topics[tIndex].isCompleted = !subject.topics[tIndex].isCompleted;
        _db.updateSubject(_uid!, subject);
      }
    }
  }

  void addTopic(String subjectId, String topicName) {
    if (_uid == null) return;
    final sIndex = subjects.indexWhere((s) => s.id == subjectId);
    if (sIndex != -1) {
      final subject = subjects[sIndex];
      subject.topics.add(Topic(id: DateTime.now().millisecondsSinceEpoch.toString(), name: topicName));
      _db.updateSubject(_uid!, subject);
    }
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    customBackgroundColor = null; // Clear custom background so it defaults to the correct light/dark color
    notifyListeners();
  }
}
