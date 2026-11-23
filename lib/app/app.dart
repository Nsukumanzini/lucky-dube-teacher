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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2869f0))
              .copyWith(
                  primary: const Color(0xff2869f0),
                  surface: Colors.white,
                  onSurface: const Color(0xff17233a)),
          scaffoldBackgroundColor: const Color(0xfff2f5fa),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              shape: Border(bottom: BorderSide(color: Color(0xffdce5ef)))),
          dividerTheme:
              const DividerThemeData(color: Color(0xffe5ebf3), thickness: 1),
          cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xffdce5ef)))),
          filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 46),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)))),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 44),
                  side: const BorderSide(color: Color(0xffdce5ef)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)))),
          chipTheme: ChipThemeData(
              side: const BorderSide(color: Color(0xffdce5ef)),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xffe8f0ff),
              labelStyle: const TextStyle(fontSize: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9))),
          navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Color(0xffe8f0ff),
              labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 10))),
          inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xfff9fbfd),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: Color(0xffd9e2ed))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: Color(0xffd9e2ed)))),
        ),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                    (repo.state['textScale'] as num?)?.toDouble() ?? 1)),
            child: child!));
  }
}
