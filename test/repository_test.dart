import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucky_dube_teacher/data/teacher_repository.dart';

void main() {
  late LocalTeacherRepository r;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    r = LocalTeacherRepository(await SharedPreferences.getInstance());
    await r.signIn('T1001', 'Learn123!', true);
  });
  test('teacher credentials only and assigned class scopes', () async {
    expect(await r.signIn('LD80001', 'Learn123!', true), false);
    expect(await r.signIn('T1002', 'wrong', true), false);
    await r.signIn('T1002', 'Learn123!', true);
    expect(r.classes.map((c) => c.id), ['8A', '9A']);
    expect(() => r.roster('10A'), throwsStateError);
  });
  test('content edits persist and do not cross teacher profiles', () async {
    final task = r.ofKind('Assignment').first;
    await r.saveRecord(TeachingRecord(
        id: task.id,
        teacherId: r.teacher.id,
        classId: task.classId,
        kind: task.kind,
        title: 'Updated task',
        body: 'New instructions',
        date: '2026-11-28',
        status: 'Draft'));
    expect(r.record(task.id).status, 'Draft');
    final restored = LocalTeacherRepository(r.preferences);
    expect(restored.record(task.id).title, 'Updated task');
    await r.signIn('T1002', 'Learn123!', true);
    expect(r.records.any((x) => x.id == task.id), false);
  });
  test('rejects publishing content outside assigned classes', () async {
    await r.signIn('T1002', 'Learn123!', true);
    await expectLater(
        r.saveRecord(const TeachingRecord(
            id: 'bad',
            teacherId: 'T1002',
            classId: '10A',
            kind: 'Lesson',
            title: 'Title',
            body: 'Body',
            date: '2026-11-26')),
        throwsStateError);
  });
  test('mark drafts are excluded until published and bounded to total',
      () async {
    final task = r.ofKind('Assignment').first;
    final learner = r.submissions(task).first;
    expect(r.average(task.classId), null);
    await r
        .saveMark(MarkRecord(task.id, learner.id, 40, 'Well explained', false));
    expect(r.average(task.classId), null);
    await r
        .saveMark(MarkRecord(task.id, learner.id, 40, 'Well explained', true));
    expect(r.average(task.classId), 80);
    await expectLater(
        r.saveMark(MarkRecord(task.id, learner.id, 51, 'Invalid score', true)),
        throwsArgumentError);
  });
  test('attendance requires every valid learner and survives reload', () async {
    final c = r.classes.first.id;
    await expectLater(
        r.saveAttendance(c, '2026-11-26', {}), throwsArgumentError);
    final statuses = {for (final learner in r.roster(c)) learner.id: 'Present'};
    statuses[r.roster(c).first.id] = 'Late';
    await r.saveAttendance(c, '2026-11-26', statuses);
    expect(LocalTeacherRepository(r.preferences).attendance(c, '2026-11-26'),
        statuses);
  });
  test('message sending remains authorised and local', () async {
    await r.sendMessage('8A', 'Please review the guide.');
    expect((r.value('messages-8A') as List).length, 2);
    await r.signIn('T1002', 'Learn123!', true);
    await expectLater(r.sendMessage('10A', 'No access'), throwsStateError);
  });
  test('reset clears only the active teacher', () async {
    await r.put('private-note', 'Teacher one');
    await r.signIn('T1002', 'Learn123!', true);
    await r.put('private-note', 'Teacher two');
    await r.reset();
    expect(r.value('private-note'), null);
    await r.signIn('T1001', 'Learn123!', true);
    expect(r.value('private-note'), 'Teacher one');
  });
  test('language preferences persist', () async {
    await r.setLanguage('zu');
    expect(LocalTeacherRepository(r.preferences).language, 'zu');
  });
}
