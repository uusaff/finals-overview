import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference _subjectsRef(String uid) => _db.collection('users').doc(uid).collection('subjects');
  CollectionReference _examsRef(String uid) => _db.collection('users').doc(uid).collection('exams');

  // --- Subjects ---

  Stream<List<Subject>> streamSubjects(String uid) {
    return _subjectsRef(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subject.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addSubject(String uid, Subject subject) async {
    await _subjectsRef(uid).doc(subject.id).set(subject.toMap());
  }

  Future<void> updateSubject(String uid, Subject subject) async {
    await _subjectsRef(uid).doc(subject.id).update(subject.toMap());
  }

  Future<void> deleteSubject(String uid, String subjectId) async {
    await _subjectsRef(uid).doc(subjectId).delete();
  }

  // --- Exams ---

  Stream<List<Exam>> streamExams(String uid) {
    return _examsRef(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Exam.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addExam(String uid, Exam exam) async {
    await _examsRef(uid).doc(exam.id).set(exam.toMap());
  }

  Future<void> updateExam(String uid, Exam exam) async {
    await _examsRef(uid).doc(exam.id).update(exam.toMap());
  }

  Future<void> deleteExam(String uid, String examId) async {
    await _examsRef(uid).doc(examId).delete();
  }
}
