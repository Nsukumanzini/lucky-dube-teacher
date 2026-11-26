import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class Teacher {
  final String id, name, subject;
  final List<String> classIds;
  const Teacher(this.id, this.name, this.subject, this.classIds);
}

@immutable
class TeachingClass {
  final String id, label, room;
  final int grade;
  const TeachingClass(this.id, this.label, this.grade, this.room);
}

@immutable
class Learner {
  final String id, name, classId;
  const Learner(this.id, this.name, this.classId);
}

@immutable
class TeachingRecord {
  final String id, teacherId, classId, kind, title, body, date, status;
  final int maxMarks;
  final Map<String, String> attachments;
  const TeachingRecord(
      {required this.id,
      required this.teacherId,
      required this.classId,
      required this.kind,
      required this.title,
      required this.body,
      required this.date,
      this.status = 'Draft',
      this.maxMarks = 50,
      this.attachments = const {}});
  factory TeachingRecord.fromJson(Map<String, dynamic> j) => TeachingRecord(
      id: j['id'] as String,
      teacherId: j['teacherId'] as String,
      classId: j['classId'] as String,
      kind: j['kind'] as String,
      title: j['title'] as String,
      body: j['body'] as String,
      date: j['date'] as String,
      status: j['status'] as String,
      maxMarks: j['maxMarks'] as int,
      attachments: Map<String, String>.from(j['attachments'] ?? {}));
  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'classId': classId,
        'kind': kind,
        'title': title,
        'body': body,
        'date': date,
        'status': status,
        'maxMarks': maxMarks,
        'attachments': attachments
      };
}

@immutable
class MarkRecord {
  final String taskId, learnerId, feedback;
  final int mark;
  final bool published;
  const MarkRecord(
      this.taskId, this.learnerId, this.mark, this.feedback, this.published);
  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'learnerId': learnerId,
        'mark': mark,
        'feedback': feedback,
        'published': published
      };
  factory MarkRecord.fromJson(Map<String, dynamic> j) => MarkRecord(
      j['taskId'], j['learnerId'], j['mark'], j['feedback'], j['published']);
}

abstract class TeacherRepository extends ChangeNotifier {
  List<Teacher> get teachers;
  Teacher? get currentTeacher;
  List<TeachingClass> get classes;
  List<TeachingRecord> get records;
  Future<bool> signIn(String id, String password, bool remember);
  Future<void> saveRecord(TeachingRecord record);
  Future<void> saveMark(MarkRecord mark);
  Future<void> saveAttendance(
      String classId, String date, Map<String, String> statuses);
}

class LocalTeacherRepository extends TeacherRepository {
  final SharedPreferences preferences;
  final Map<String, dynamic> state;
  LocalTeacherRepository(this.preferences)
      : state =
            jsonDecode(preferences.getString('lucky_dube_teacher_v1') ?? '{}')
                as Map<String, dynamic>;
  static const schoolName = 'Lucky Dube Secondary School of Performing Arts';
  static const owner = 'Optimal Growth Technologies SA';
  @override
  final teachers = const [
    Teacher('T1001', 'Nolwazi Maseko', 'English', ['8A', '9A', '10A']),
    Teacher('T1002', 'Andile Dlamini', 'Mathematics', ['8A', '9A']),
    Teacher('T1003', 'Priya Khumalo', 'Creative Arts', ['8A', '10A'])
  ];
  static const allClasses = [
    TeachingClass('8A', 'Grade 8A', 8, 'B1'),
    TeachingClass('9A', 'Grade 9A', 9, 'B2'),
    TeachingClass('10A', 'Grade 10A', 10, 'Arts studio')
  ];
  @override
  Teacher? get currentTeacher {
    final list = teachers.where((t) => t.id == state['session']);
    return list.isEmpty ? null : list.first;
  }

  Teacher get teacher => currentTeacher ?? (throw StateError('Sign in first'));
  @override
  List<TeachingClass> get classes =>
      allClasses.where((c) => teacher.classIds.contains(c.id)).toList();
  List<Learner> get learners => [
        for (final c in allClasses)
          for (var i = 0; i < 9; i++)
            Learner(
                'LD${c.grade}${(i + 1).toString().padLeft(c.grade == 10 ? 3 : 4, '0')}',
                [
                  'Ayanda Mokoena',
                  'Lethabo Nkosi',
                  'Sipho Dlamini',
                  'Zanele Mthembu',
                  'Thabo Sithole',
                  'Naledi Molefe',
                  'Sibusiso Zulu',
                  'Anele Jacobs',
                  'Bongani Ndlovu'
                ][(i + c.grade - 8) % 9],
                c.id)
      ];
  List<Learner> roster(String classId) {
    checkClass(classId);
    return learners.where((l) => l.classId == classId).toList();
  }

  void checkClass(String id) {
    if (!teacher.classIds.contains(id)) {
      throw StateError('Class not assigned to this teacher');
    }
  }

  String scoped(String key) => '${teacher.id}:$key';
  dynamic value(String key, [dynamic fallback]) =>
      state[scoped(key)] ?? fallback;
  Future<void> persist() async {
    await preferences.setString('lucky_dube_teacher_v1', jsonEncode(state));
    notifyListeners();
  }

  Future<void> put(String key, dynamic value) async {
    state[scoped(key)] = value;
    await persist();
  }

  String get language => 'en';
  Future<void> setLanguage(String code) async {}

  @override
  Future<bool> signIn(String id, String password, bool remember) async {
    if (!teachers.any((t) => t.id == id) || password != 'Learn123!') {
      return false;
    }
    state['session'] = id;
    state['remember'] = remember;
    await persist();
    return true;
  }

  Future<void> signOut() async {
    state.remove('session');
    await persist();
  }

  @override
  List<TeachingRecord> get records {
    final base = [
      for (final c in classes)
        for (final kind in [
          'Lesson',
          'Classwork',
          'Assignment',
          'Resource',
          'Announcement',
          'Rehearsal'
        ])
          TeachingRecord(
              id: '${teacher.id}-${c.id}-$kind',
              teacherId: teacher.id,
              classId: c.id,
              kind: kind,
              title: kind == 'Classwork'
                  ? '${teacher.subject}: class activity'
                  : kind == 'Lesson'
                      ? '${teacher.subject}: ideas into practice'
                      : kind == 'Assignment'
                          ? '${teacher.subject}: Term 4 task'
                          : kind == 'Resource'
                              ? '${teacher.subject}: original revision notes'
                              : kind == 'Announcement'
                                  ? 'Prepare for the final learning week'
                                  : 'Creative showcase rehearsal',
              body: kind == 'Classwork'
                  ? 'Use the lesson notes to complete this in-class activity. Show your working, discuss your approach and share one reflection with the class.'
                  : kind == 'Assignment'
                      ? 'Explain the key idea in your own words. Give a worked example and reflect on how you checked your answer. Submit a written response.'
                      : kind == 'Lesson'
                          ? 'Learning objectives: identify the key concept, apply it in an example and explain your reasoning.\n\nStarter: recall prior learning (5 minutes).\nExplore: work through an original example (15 minutes).\nPractise: complete a paired activity (15 minutes).\nReflect: write an exit ticket (5 minutes).'
                          : kind == 'Resource'
                              ? 'Original study guide\n\n1. Read the question carefully.\n2. Identify what is known.\n3. Explain your method and check your answer.\n\nCreated by Optimal Growth Technologies SA.'
                              : 'Bring your workbook and learning materials. We will review progress and prepare for the next activity.',
              date: kind == 'Assignment' ? '2026-11-27' : '2026-11-26',
              status: 'Published')
    ];
    final saved = List<dynamic>.from(value('records', []))
        .map((j) => TeachingRecord.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    final ids = saved.map((r) => r.id).toSet();
    return [...base.where((r) => !ids.contains(r.id)), ...saved]
        .where((r) =>
            r.teacherId == teacher.id && teacher.classIds.contains(r.classId))
        .toList();
  }

  List<TeachingRecord> ofKind(String kind) =>
      records.where((r) => r.kind == kind).toList();
  TeachingRecord record(String id) => records.firstWhere((r) => r.id == id);
  @override
  Future<void> saveRecord(TeachingRecord record) async {
    checkClass(record.classId);
    if (record.teacherId != teacher.id) {
      throw StateError('Cannot edit another teacher’s content');
    }
    if (record.title.trim().isEmpty ||
        record.body.trim().isEmpty ||
        record.maxMarks < 1 ||
        record.maxMarks > 1000 ||
        DateTime.tryParse(record.date) == null ||
        !['Draft', 'Published'].contains(record.status) ||
        ![
          'Lesson',
          'Classwork',
          'Assignment',
          'Resource',
          'Announcement',
          'Rehearsal',
          'Reminder'
        ].contains(record.kind)) {
      throw ArgumentError('Enter valid content, date and total marks');
    }
    final list = List<dynamic>.from(value('records', []));
    list.removeWhere((j) => j['id'] == record.id);
    list.add(record.toJson());
    await put('records', list);
  }

  List<Learner> submissions(TeachingRecord task) {
    if (task.teacherId != teacher.id) {
      throw StateError('Submission not assigned to this teacher');
    }
    checkClass(task.classId);
    if (task.status != 'Published' ||
        task.id != '${task.teacherId}-${task.classId}-Assignment') {
      return [];
    }
    return roster(task.classId)
        .asMap()
        .entries
        .where((entry) => entry.key % 3 != 2)
        .map((entry) => entry.value)
        .toList();
  }

  String responseFor(Learner learner) =>
      'I identified the key idea, worked through an example and checked each step. My example connects the topic to everyday life. I would improve my explanation by adding more evidence.\n\nSubmitted by ${learner.name} • 25 November 2026';
  List<MarkRecord> get marks => List<dynamic>.from(value('marks', []))
      .map((j) => MarkRecord.fromJson(Map<String, dynamic>.from(j)))
      .toList();
  MarkRecord? markFor(String task, String learner) {
    final found =
        marks.where((m) => m.taskId == task && m.learnerId == learner);
    return found.isEmpty ? null : found.first;
  }

  @override
  Future<void> saveMark(MarkRecord mark) async {
    final task = record(mark.taskId);
    checkClass(task.classId);
    if (task.kind != 'Assignment' ||
        !submissions(task).any((l) => l.id == mark.learnerId) ||
        mark.mark < 0 ||
        mark.mark > task.maxMarks ||
        mark.feedback.trim().isEmpty) {
      throw ArgumentError(
          'Enter a valid mark and feedback for an assigned submission');
    }
    final list = marks
        .where((m) => m.taskId != mark.taskId || m.learnerId != mark.learnerId)
        .map((m) => m.toJson())
        .toList();
    list.add(mark.toJson());
    await put('marks', list);
  }

  int get pendingMarking => ofKind('Assignment').fold(
      0,
      (sum, t) =>
          sum +
          submissions(t)
              .where((l) => markFor(t.id, l.id)?.published != true)
              .length);
  double? average(String classId) {
    final taskIds = ofKind('Assignment')
        .where((t) => t.classId == classId)
        .map((t) => t.id)
        .toSet();
    final published =
        marks.where((m) => m.published && taskIds.contains(m.taskId)).toList();
    if (published.isEmpty) return null;
    return published
            .map((m) => m.mark / record(m.taskId).maxMarks * 100)
            .reduce((a, b) => a + b) /
        published.length;
  }

  Map<String, String> attendance(String classId, String date) {
    checkClass(classId);
    return Map<String, String>.from(value('attendance-$classId-$date', {}));
  }

  @override
  Future<void> saveAttendance(
      String classId, String date, Map<String, String> statuses) async {
    checkClass(classId);
    final ids = roster(classId).map((l) => l.id).toSet();
    if (DateTime.tryParse(date) == null ||
        statuses.length != ids.length ||
        !statuses.keys.every(ids.contains) ||
        !statuses.values
            .every(['Present', 'Absent', 'Late', 'Excused'].contains)) {
      throw ArgumentError('Record a status for every learner');
    }
    await put('attendance-$classId-$date', statuses);
  }

  Future<void> sendMessage(String classId, String body) async {
    checkClass(classId);
    if (body.trim().isEmpty) return;
    final list = List<Map<String, dynamic>>.from(
        List<dynamic>.from(value('messages-$classId', []))
            .map((v) => Map<String, dynamic>.from(v)));
    list.add({'sender': 'You', 'body': body.trim(), 'time': '10:20'});
    await put('messages-$classId', list);
  }

  Future<void> reset() async {
    final id = teacher.id;
    state.removeWhere((key, value) => key.startsWith('$id:'));
    await persist();
  }
}
