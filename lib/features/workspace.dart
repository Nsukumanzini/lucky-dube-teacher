// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../data/teacher_repository.dart';
import '../app/localization/app_language.dart';
import '../shared/components/teacher_components.dart';
import '../shared/components/learner_visuals.dart';
import '../shared/components/teacher_shell.dart';
import '../shared/components/staff_components.dart';
import '../shared/components/premium_surface.dart';
import 'dashboard/teaching_dashboard.dart';
import 'dashboard/teaching_library.dart';

class TeacherLogin extends ConsumerStatefulWidget {
  const TeacherLogin({super.key});
  @override
  ConsumerState<TeacherLogin> createState() => _TeacherLoginState();
}

class _TeacherLoginState extends ConsumerState<TeacherLogin> {
  final id = TextEditingController(text: 'T1001'),
      password = TextEditingController(text: 'Learn123!');
  bool show = false, remember = true;
  String? error;
  @override
  void dispose() {
    id.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(teacherRepositoryProvider);
    final formPanel = Panel(
        'Welcome to your teaching workspace',
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const LText('Plan with purpose. Support every learner.'),
          const SizedBox(height: 24),
          TextField(
              controller: id,
              decoration:
                  InputDecoration(labelText: tr(context, 'Teacher number'))),
          const SizedBox(height: 14),
          TextField(
              controller: password,
              obscureText: !show,
              decoration: InputDecoration(
                  labelText: tr(context, 'Password'),
                  suffixIcon: IconButton(
                      tooltip: tr(context, 'Show password'),
                      onPressed: () => setState(() => show = !show),
                      icon: Icon(show
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined)))),
          CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: remember,
              onChanged: (v) => setState(() => remember = v!),
              title: const LText('Remember me')),
          if (error != null)
            LText(error!, style: const TextStyle(color: Colors.red)),
          FilledButton(
              onPressed: () async {
                if (!await repo.signIn(
                        id.text.trim(), password.text, remember) &&
                    mounted) {
                  setState(
                      () => error = 'Check your teacher number and password.');
                }
              },
              child: const LText('Sign in')),
          const SizedBox(height: 24),
          const LText('Quick sign-in',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const LText('Access password: Learn123!'),
          const SizedBox(height: 10),
          for (final t in repo.teachers)
            OutlinedButton(
                onPressed: () => repo.signIn(t.id, 'Learn123!', remember),
                child: LText('${t.name} • ${t.subject}')),
          const SizedBox(height: 16),
          const LText(
              'Accounts and class allocations are school-managed. This workspace stores changes on this device only.',
              style: TextStyle(fontSize: 12, height: 1.5)),
          const SizedBox(height: 16),
          const LText(LocalTeacherRepository.owner,
              style: TextStyle(fontSize: 11))
        ]));
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: const LiquidGlassBar(),
            title: const LText('Lucky Dube • Teachers',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            actions: const [TeacherLanguage()]),
        body: SafeArea(child: LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth >= 1000;
          final brand = Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                  color: const Color(0xffe9f2ff),
                  border: Border.all(color: const Color(0xffcee0fa)),
                  borderRadius: BorderRadius.circular(26)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LText('TEACHING WORKSPACE',
                        style: TextStyle(
                            fontSize: 11,
                            color: blue,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 26),
                    const LText('Great teaching.\nClearer possibilities.',
                        style: TextStyle(
                            fontSize: 40,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: ink)),
                    const SizedBox(height: 20),
                    const LText(
                        'Plan your lessons, support every learner and make room for creativity.',
                        style:
                            TextStyle(fontSize: 15, color: muted, height: 1.8)),
                    const SizedBox(height: 24),
                    const SizedBox(
                        height: 200,
                        child: Center(child: LearningIllustration())),
                    const SizedBox(height: 22),
                    const Wrap(spacing: 8, runSpacing: 8, children: [
                      StatusPill('Plan'),
                      StatusPill('Teach'),
                      StatusPill('Support')
                    ]),
                  ]));
          return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 40 : 20),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1140),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Expanded(flex: 6, child: brand),
                                  const SizedBox(width: 44),
                                  Expanded(flex: 5, child: formPanel)
                                ])
                          : ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: formPanel))));
        })));
  }
}

class TeacherWorkspace extends ConsumerStatefulWidget {
  final String page;
  const TeacherWorkspace({super.key, required this.page});
  @override
  ConsumerState<TeacherWorkspace> createState() => _TeacherWorkspaceState();
}

class _TeacherWorkspaceState extends ConsumerState<TeacherWorkspace> {
  String search = '', filter = 'All';
  DateTime day = DateTime(2026, 11, 26);
  LocalTeacherRepository get r => ref.read(teacherRepositoryProvider);
  static const destinations = {
    'home': 'Home',
    'classes': 'My classes',
    'planner': 'Lesson planner',
    'resources': 'Resources',
    'assignments': 'Assignments',
    'marking': 'Marking',
    'attendance': 'Attendance',
    'results': 'Learner progress',
    'messages': 'Messages',
    'calendar': 'Calendar',
    'announcements': 'Announcements',
    'arts': 'Performing arts',
    'settings': 'Profile & settings'
  };
  static const icons = [
    Icons.dashboard_outlined,
    Icons.groups_outlined,
    Icons.event_note_outlined,
    Icons.folder_outlined,
    Icons.assignment_outlined,
    Icons.fact_check_outlined,
    Icons.how_to_reg_outlined,
    Icons.insights_outlined,
    Icons.forum_outlined,
    Icons.calendar_month_outlined,
    Icons.campaign_outlined,
    Icons.theater_comedy_outlined,
    Icons.person_outline
  ];
  void go(String page) {
    setState(() {
      search = '';
      filter = 'All';
    });
    context.go('/$page');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(teacherRepositoryProvider);
    if (r.currentTeacher == null) return const SizedBox();
    return TeacherShell(
        page: widget.page,
        navigation: destinations,
        icon: (page) => destinations.containsKey(page)
            ? icons[destinations.keys.toList().indexOf(page)]
            : Icons.search,
        navigate: go,
        repository: r,
        child: content());
  }

  Widget content() {
    switch (widget.page) {
      case 'home':
        return dashboard();
      case 'search':
        return workspaceSearch();
      case 'classes':
        return classList();
      case 'planner':
        return recordList('Lesson');
      case 'resources':
        return recordList('Resource');
      case 'assignments':
        return recordList('Assignment');
      case 'announcements':
        return recordList('Announcement');
      case 'arts':
        return recordList('Rehearsal');
      case 'marking':
        return marking();
      case 'attendance':
        return attendance();
      case 'results':
        return results();
      case 'messages':
        return messages();
      case 'calendar':
        return calendar();
      case 'settings':
        return settings();
      default:
        return const PageHeading('Page not found',
            'Use the navigation to return to your workspace.');
    }
  }

  @override
  void didUpdateWidget(covariant TeacherWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      search = '';
      filter = 'All';
    }
  }

  Widget dashboard() => TeachingDashboard(repository: r, navigate: go);
  Widget recordList(String kind) =>
      TeachingLibrary(key: ValueKey(kind), repository: r, kind: kind);
  Widget marking() => MarkingQueue(repository: r);

  Widget classList() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('My classes',
            'Your teaching portfolio • School-managed class allocations'),
        LayoutBuilder(builder: (context, box) {
          final count = box.maxWidth >= 1000
              ? 3
              : box.maxWidth >= 650
                  ? 2
                  : 1;
          return Wrap(spacing: 16, runSpacing: 16, children: [
            for (final c in r.classes)
              SizedBox(
                  width: (box.maxWidth - 16 * (count - 1)) / count,
                  child: LiquidGlassSurface(
                      padding: EdgeInsets.zero,
                      child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: const Color(0xffe8f1ff),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Icon(
                                          Icons.menu_book_outlined,
                                          color: blue,
                                          size: 24)),
                                  const Spacer(),
                                  StatusPill('Grade ${c.grade}')
                                ]),
                                const SizedBox(height: 22),
                                Text(c.label,
                                    style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                Text(r.teacher.subject,
                                    style: const TextStyle(
                                        fontSize: 13, color: muted)),
                                const SizedBox(height: 18),
                                LText(
                                    '${r.roster(c.id).length} learners • Room ${c.room}',
                                    style: const TextStyle(
                                        fontSize: 12, color: muted)),
                                const SizedBox(height: 14),
                                LText(
                                    r.average(c.id) == null
                                        ? 'No published results yet'
                                        : '${r.average(c.id)!.toStringAsFixed(1)}% class average',
                                    style: const TextStyle(
                                        fontSize: 12, color: muted)),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 8),
                                Wrap(spacing: 8, runSpacing: 8, children: [
                                  TextButton.icon(
                                      onPressed: () =>
                                          context.push('/class/${c.id}'),
                                      icon: const Icon(Icons.arrow_forward,
                                          size: 17),
                                      label: const LText('Open class')),
                                  OutlinedButton.icon(
                                      onPressed: () =>
                                          context.push('/attendance/${c.id}'),
                                      icon: const Icon(
                                          Icons.how_to_reg_outlined,
                                          size: 17),
                                      label: const LText('Register'))
                                ]),
                              ]))))
          ]);
        }),
      ]);

  Widget workspaceSearch() {
    final needle = search.trim().toLowerCase();
    final modules = destinations.entries.where((e) =>
        '${e.value} ${tr(context, e.value)}'.toLowerCase().contains(needle));
    final records = needle.isEmpty
        ? <TeachingRecord>[]
        : r.records
            .where((e) => '${e.id} ${e.title} ${e.body} ${e.classId}'
                .toLowerCase()
                .contains(needle))
            .toList();
    final learners = needle.isEmpty
        ? <Learner>[]
        : r.classes
            .expand((c) => r.roster(c.id))
            .where((l) =>
                '${l.name} ${l.id} ${l.classId}'.toLowerCase().contains(needle))
            .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeading('Search workspace',
          'Find teaching tools, content and learners in your assigned classes.'),
      TextField(
          autofocus: true,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: tr(context, 'Search your teaching workspace')),
          onChanged: (value) => setState(() => search = value)),
      const SizedBox(height: 22),
      DashboardPanel(
          title: 'Teaching tools',
          subtitle: 'Open a teaching workflow',
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in modules)
              ActionChip(label: LText(e.value), onPressed: () => go(e.key))
          ])),
      if (needle.isNotEmpty) ...[
        const SizedBox(height: 18),
        DashboardPanel(
            title: 'Learners',
            subtitle: '${learners.length} matching learners',
            child: Column(children: [
              if (learners.isEmpty)
                const EmptyPanel('No matching learners',
                    'Search by learner name, number or class.'),
              for (final l in learners.take(30))
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline, color: blue),
                    title: Text(l.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('${l.id} • ${l.classId}',
                        style: const TextStyle(fontSize: 11, color: muted)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context.push('/class/${l.classId}')),
            ])),
        const SizedBox(height: 18),
        DashboardPanel(
            title: 'Teaching content',
            subtitle: '${records.length} matching items',
            child: Column(children: [
              if (records.isEmpty)
                const EmptyPanel(
                    'No matching content', 'Try another title or class.'),
              for (final item in records.take(30))
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.description_outlined, color: blue),
                    title: Text(item.title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: LText(
                        '${item.kind} • ${item.classId} • ${item.status}',
                        style: const TextStyle(fontSize: 11, color: muted)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context
                        .push('/record/${Uri.encodeComponent(item.id)}')),
              if (records.length > 30)
                const LText('Refine your search to see more specific results.',
                    style: TextStyle(fontSize: 12, color: muted)),
            ])),
      ],
    ]);
  }

  Widget attendance() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('Attendance',
            'Complete and save a register for each teaching class'),
        for (final c in r.classes)
          LiquidGlassSurface(
              padding: EdgeInsets.zero,
              child: ActionTile(
                  c.label,
                  '${r.attendance(c.id, '2026-11-26').length} / ${r.roster(c.id).length} statuses recorded today',
                  Icons.how_to_reg_outlined,
                  () => context.push('/attendance/${c.id}')))
      ]);
  Widget results() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('Learner progress',
            'Published marks only • Calculated from your marked assignments'),
        for (final c in r.classes)
          Panel(
              c.label,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                LText(
                    r.average(c.id) == null
                        ? 'No published results yet'
                        : '${r.average(c.id)!.toStringAsFixed(1)}% class average',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 14),
                if (r.average(c.id) != null)
                  LinearProgressIndicator(value: r.average(c.id)! / 100),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: () => context.push('/class/${c.id}'),
                    child: const LText('View learner progress'))
              ]))
      ]);
  Widget messages() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading(
            'Messages', 'School-managed channels for your assigned classes'),
        const DashboardPanel(
            title: 'Class communication',
            subtitle:
                'Messages stay on this device. Automated practice replies are clearly labelled.',
            child: LText(
                'Messages are saved on this device and are not delivered to learners or staff.',
                style: TextStyle(fontSize: 12, color: muted, height: 1.7))),
        const SizedBox(height: 18),
        TextField(
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: tr(context, 'Search class channels')),
            onChanged: (value) => setState(() => search = value)),
        const SizedBox(height: 18),
        for (final c in r.classes.where((c) => '${c.label} ${r.teacher.subject}'
            .toLowerCase()
            .contains(search.toLowerCase())))
          Builder(builder: (context) {
            final messages =
                List<dynamic>.from(r.value('messages-${c.id}', []));
            return LiquidGlassSurface(
                padding: EdgeInsets.zero,
                child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.push('/conversation/${c.id}'),
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffe8f1ff),
                                      borderRadius: BorderRadius.circular(14)),
                                  child: const Icon(Icons.forum_outlined,
                                      color: blue, size: 23)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('${c.label} • ${r.teacher.subject}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 7),
                                    LText(
                                        messages.isEmpty
                                            ? 'No messages yet. Start a class conversation.'
                                            : messages.last['body'].toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: muted,
                                            height: 1.6)),
                                    const SizedBox(height: 10),
                                    LText(
                                        '${messages.length} messages • Moderated class channel',
                                        style: const TextStyle(
                                            fontSize: 10, color: muted))
                                  ])),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right,
                                  color: blue, size: 20),
                            ]))));
          }),
        if (r.classes
            .where((c) => '${c.label} ${r.teacher.subject}'
                .toLowerCase()
                .contains(search.toLowerCase()))
            .isEmpty)
          const EmptyPanel(
              'No matching channels', 'Try a different class name.'),
      ]);
  Widget calendar() {
    final events = r.records
        .where((item) => item.date == day.toIso8601String().substring(0, 10));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeading('Teaching calendar',
          'Your lessons, deadlines, rehearsals and personal reminders'),
      Wrap(spacing: 10, children: [
        OutlinedButton.icon(
            onPressed: () async {
              final selected = await showDatePicker(
                  context: context,
                  initialDate: day,
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2028));
              if (selected != null) setState(() => day = selected);
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(day.toIso8601String().substring(0, 10))),
        FilledButton.icon(
            onPressed: () => context.push('/new/Reminder'),
            icon: const Icon(Icons.add),
            label: const LText('Personal reminder'))
      ]),
      const SizedBox(height: 20),
      if (events.isEmpty)
        const Panel('A little breathing room',
            LText('No activities scheduled for this date.')),
      for (final e in events)
        LiquidGlassSurface(
            padding: EdgeInsets.zero,
            child: ActionTile(
                e.title,
                '${e.classId} • ${e.kind} • ${e.status}',
                Icons.event,
                () => context.push('/record/${Uri.encodeComponent(e.id)}')))
    ]);
  }

  Widget settings() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('Profile & settings',
            'Your teaching identity and local preferences'),
        Panel(
            r.teacher.name,
            LText(
                '${r.teacher.id} • ${r.teacher.subject}\n${LocalTeacherRepository.schoolName}\nAssigned classes: ${r.teacher.classIds.join(', ')}\nAcademic year: 2026')),
        const Panel('Language', TeacherLanguage()),
        Panel(
            'Accessibility',
            Column(children: [
              const LText('Text size'),
              Slider(
                  value: (r.state['textScale'] as num?)?.toDouble() ?? 1,
                  min: 1,
                  max: 1.4,
                  divisions: 4,
                  onChanged: (v) {
                    r.state['textScale'] = v;
                    r.persist();
                  })
            ])),
        Panel(
            'Application information',
            const LText(
                'Developed and owned by Optimal Growth Technologies SA. No school endorsement is implied. Teacher and learner profiles are fictional. Changes are saved on this device only. Do not enter sensitive personal information.')),
        OutlinedButton.icon(
            onPressed: () async {
              if (await confirmLocalReset(context)) {
                await r.reset();
                if (mounted) savedMessage(context);
              }
            },
            icon: const Icon(Icons.restart_alt),
            label: const LText('Reset local information')),
        const SizedBox(height: 12),
        TextButton.icon(
            onPressed: r.signOut,
            icon: const Icon(Icons.logout),
            label: const LText('Sign out'))
      ]);
}
