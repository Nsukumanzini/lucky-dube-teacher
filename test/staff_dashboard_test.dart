// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucky_dube_teacher/main.dart';
import 'package:lucky_dube_teacher/app/app.dart';
import 'package:lucky_dube_teacher/data/teacher_repository.dart';
import 'package:lucky_dube_teacher/features/workspace.dart';
import 'package:lucky_dube_teacher/features/workflow_screens.dart';
import 'package:lucky_dube_teacher/features/dashboard/submission_table.dart';
import 'package:lucky_dube_teacher/shared/components/staff_components.dart';

Future<LocalTeacherRepository> mount(WidgetTester tester,
    {double width = 1440,
    double textScale = 1,
    String teacher = 'T1001'}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final r = LocalTeacherRepository(await SharedPreferences.getInstance());
  await r.signIn(teacher, 'Learn123!', true);
  r.state['textScale'] = textScale;
  await tester.pumpWidget(ProviderScope(
      overrides: [teacherRepositoryProvider.overrideWith((ref) => r)],
      child: const TeacherApp()));
  await tester.pumpAndSettle();
  return r;
}

void main() {
  testWidgets('staff metrics reflect assigned classes and published marking',
      (tester) async {
    final r = await mount(tester, teacher: 'T1002');
    MetricCard metric(String title) => tester
        .widgetList<MetricCard>(find.byType(MetricCard))
        .firstWhere((x) => x.title == title);
    expect(metric('Learners').value, '18');
    expect(metric('Awaiting feedback').value, '12');
    expect(metric('Upcoming assignments').value, '2');
    final task = r.ofKind('Assignment').first;
    final learner = r.submissions(task).first;
    await r
        .saveMark(MarkRecord(task.id, learner.id, 42, 'Well explained.', true));
    await tester.pumpAndSettle();
    expect(metric('Awaiting feedback').value, '11');
    expect(r.average('8A'), 84);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'workspace search retains input and restricts results to assigned classes',
      (tester) async {
    await mount(tester, teacher: 'T1002');
    await tester.tap(find.text('Search workspace'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '10A');
    await tester.pumpAndSettle();
    expect(find.text('0 matching learners'), findsOneWidget);
    expect(find.text('0 matching items'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'LD80001');
    await tester.pumpAndSettle();
    expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'LD80001');
    expect(find.text('1 matching learners'), findsOneWidget);
    await tester.ensureVisible(find.text('Ayanda Mokoena'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayanda Mokoena'));
    await tester.pumpAndSettle();
    expect(find.byType(ClassScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('academic library paginates and search resets pagination',
      (tester) async {
    final r = await mount(tester);
    for (var i = 0; i < 7; i++) {
      await r.saveRecord(TeachingRecord(
          id: 'extra-$i',
          teacherId: r.teacher.id,
          classId: '8A',
          kind: 'Lesson',
          title: 'Unique lesson $i',
          body: 'Original teaching activities.',
          date: '2026-11-26'));
    }
    final router = GoRouter.of(tester.element(find.byType(TeacherWorkspace)));
    router.go('/planner');
    await tester.pumpAndSettle();
    expect(find.text('10 items'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Unique lesson 6');
    await tester.pumpAndSettle();
    expect(find.text('1 item'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(
        find.byWidgetPredicate((w) => w is Text && w.data == 'Unique lesson 6'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('submission table class filter opens full-screen marking',
      (tester) async {
    await mount(tester);
    final router = GoRouter.of(tester.element(find.byType(TeacherWorkspace)));
    router.go('/marking');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '9A'));
    await tester.pumpAndSettle();
    final table = tester.widget<SubmissionTable>(find.byType(SubmissionTable));
    expect(table.entries.every((e) => e.task.classId == '9A'), true);
    expect(table.entries.length, 6);
    final firstName = table.entries.first.learner.name;
    await tester.ensureVisible(find.text(firstName));
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstName));
    await tester.pumpAndSettle();
    expect(find.byType(MarkingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mobile staff navigation reaches attendance', (tester) async {
    await mount(tester, width: 390);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();
    expect(find.text('Complete and save a register for each teaching class'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [360.0, 1024.0]) {
    testWidgets('staff workspace supports 140 percent text at $width',
        (tester) async {
      await mount(tester, width: width, textScale: 1.4);
      expect(tester.takeException(), isNull);
      final router = GoRouter.of(tester.element(find.byType(TeacherWorkspace)));
      for (final page in [
        'classes',
        'planner',
        'marking',
        'messages',
        'search'
      ]) {
        router.go('/$page');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: page);
      }
    });
  }
}
