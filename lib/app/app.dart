// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../features/workspace.dart';
import '../features/workflow_screens.dart';
import 'localization/app_language.dart';

class TeacherApp extends ConsumerStatefulWidget {
  const TeacherApp({super.key});
  @override
  ConsumerState<TeacherApp> createState() => _TeacherAppState();
}

class _TeacherAppState extends ConsumerState<TeacherApp> {
  late final router = GoRouter(
      initialLocation: '/home',
      refreshListenable: ref.read(teacherRepositoryProvider),
      redirect: (context, state) {
        final signedIn =
            ref.read(teacherRepositoryProvider).currentTeacher != null;
        if (!signedIn && state.uri.path != '/login') return '/login';
        if (signedIn && state.uri.path == '/login') return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (c, s) => const TeacherLogin()),
        GoRoute(
            path: '/class/:id',
            builder: (c, s) => ClassScreen(id: s.pathParameters['id']!)),
        GoRoute(
            path: '/new/:kind',
            builder: (c, s) => RecordEditor(kind: s.pathParameters['kind']!)),
        GoRoute(
            path: '/edit/:id',
            builder: (c, s) => RecordEditor(recordId: s.pathParameters['id']!)),
        GoRoute(
            path: '/record/:id',
            builder: (c, s) => RecordScreen(id: s.pathParameters['id']!)),
        GoRoute(
            path: '/mark/:task/:learner',
            builder: (c, s) => MarkingScreen(
                taskId: s.pathParameters['task']!,
                learnerId: s.pathParameters['learner']!)),
        GoRoute(
            path: '/attendance/:classId',
            builder: (c, s) =>
                AttendanceScreen(classId: s.pathParameters['classId']!)),
        GoRoute(
            path: '/conversation/:classId',
            builder: (c, s) =>
                ConversationScreen(classId: s.pathParameters['classId']!)),
        GoRoute(
            path: '/:page',
            builder: (c, s) =>
                TeacherWorkspace(page: s.pathParameters['page']!)),
      ]);
  @override
  void initState() {
    super.initState();
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(teacherRepositoryProvider);
    return MaterialApp.router(
        title: 'Lucky Dube • Teachers',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        locale: Locale(repo.language, 'ZA'),
        supportedLocales: const [Locale('en', 'ZA'), Locale('zu', 'ZA')],
        localizationsDelegates: const [
          AppLanguage.delegate,
          // ignore: deprecated_member_use
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          // ignore: deprecated_member_use
          GlobalCupertinoLocalizations.delegate
        ],
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff2563eb))
                    .copyWith(
                        primary: const Color(0xff2563eb),
                        surface: Colors.white,
                        onSurface: const Color(0xff22334b)),
            scaffoldBackgroundColor: const Color(0xfff7faff),
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white, scrolledUnderElevation: 0),
            cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xffe2e8f0)))),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xfff0f5fb),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none))),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                    (repo.state['textScale'] as num?)?.toDouble() ?? 1)),
            child: child!));
  }
}
