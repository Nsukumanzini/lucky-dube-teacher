// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/teacher_repository.dart';
import 'app/app.dart';

final teacherRepositoryProvider =
    ChangeNotifierProvider<LocalTeacherRepository>(
        (ref) => throw StateError('Repository must be supplied at startup'));
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository =
      LocalTeacherRepository(await SharedPreferences.getInstance());
  if (repository.state['remember'] != true) repository.state.remove('session');
  runApp(ProviderScope(
      overrides: [teacherRepositoryProvider.overrideWith((ref) => repository)],
      child: const TeacherApp()));
}
