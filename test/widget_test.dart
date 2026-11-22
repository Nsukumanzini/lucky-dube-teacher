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

void main() {
  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('teacher workspace flows at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final r = LocalTeacherRepository(await SharedPreferences.getInstance());
      await r.signIn('T1001', 'Learn123!', true);
      await tester.pumpWidget(ProviderScope(
          overrides: [teacherRepositoryProvider.overrideWith((ref) => r)],
          child: const TeacherApp()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Good morning'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final router = GoRouter.of(tester.element(find.byType(TeacherWorkspace)));
      for (final page in [
        'classes',
        'planner',
        'resources',
        'assignments',
        'marking',
        'attendance',
        'results',
        'messages',
        'calendar',
        'announcements',
        'arts',
        'settings'
      ]) {
        router.go('/$page');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: page);
      }
      router.push('/attendance/8A');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark all present'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save register'));
      await tester.pumpAndSettle();
      expect(r.attendance('8A', '2026-11-26').length, 9);
      expect(tester.takeException(), isNull);
      router.pop();
      await tester.pumpAndSettle();
      final task = r.ofKind('Assignment').first;
      final learner = r.submissions(task).first;
      router.push('/mark/${Uri.encodeComponent(task.id)}/${learner.id}');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '42');
      await tester.enterText(find.byType(TextFormField).last,
          'Clear reasoning. Include evidence next time.');
      await tester.tap(find.text('Publish result'));
      await tester.pumpAndSettle();
      expect(r.markFor(task.id, learner.id)?.published, true);
      expect(r.average('8A'), 84);
      expect(tester.takeException(), isNull);
      router.pop();
      await tester.pumpAndSettle();
      router.push('/new/Lesson');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'A new lesson');
      await tester.enterText(find.byType(TextFormField).last,
          'Objective: practise an original example and reflect.');
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();
      expect(
          r
              .ofKind('Lesson')
              .any((l) => l.title == 'A new lesson' && l.status == 'Published'),
          true);
      expect(find.byType(RecordScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      router.pop();
      await tester.pumpAndSettle();
      router.push('/conversation/8A');
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField), 'Please bring your workbooks.');
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect((r.value('messages-8A') as List).length, 2);
      expect(tester.takeException(), isNull);
    });
  }
  for (final width in [360.0, 768.0, 1440.0]) {
    testWidgets('isiZulu teacher workspace at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final r = LocalTeacherRepository(await SharedPreferences.getInstance());
      await r.signIn('T1002', 'Learn123!', true);
      await r.setLanguage('zu');
      await tester.pumpWidget(ProviderScope(
          overrides: [teacherRepositoryProvider.overrideWith((ref) => r)],
          child: const TeacherApp()));
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(TeacherWorkspace)));
      for (final page in [
        'home',
        'classes',
        'planner',
        'resources',
        'assignments',
        'marking',
        'attendance',
        'results',
        'messages',
        'calendar',
        'announcements',
        'arts',
        'settings'
      ]) {
        router.go('/$page');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '$page isiZulu at $width');
      }
      router.push('/class/10A');
      await tester.pumpAndSettle();
      expect(
          find.text(
              'Lokhu okuqukethwe akwabelwe iphrofayela yakho yokufundisa.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('teacher app exposes teacher sign-in without a role selector',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final r = LocalTeacherRepository(await SharedPreferences.getInstance());
    await tester.pumpWidget(ProviderScope(
        overrides: [teacherRepositoryProvider.overrideWith((ref) => r)],
        child: const TeacherApp()));
    await tester.pumpAndSettle();
    expect(find.text('Teacher number'), findsOneWidget);
    expect(find.textContaining('Admin'), findsNothing);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(TeacherWorkspace), findsOneWidget);
  });
}
