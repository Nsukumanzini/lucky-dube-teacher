// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../data/teacher_repository.dart';
import '../app/localization/app_language.dart';
import '../shared/components/teacher_components.dart';
import '../shared/components/learner_visuals.dart';

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
    return Scaffold(
        appBar: AppBar(
            title: const LText('Lucky Dube • Teachers'),
            actions: const [TeacherLanguage()]),
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Panel(
                        'Welcome to your teaching workspace',
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const LText(
                                  'Plan with purpose. Support every learner.'),
                              const SizedBox(height: 24),
                              TextField(
                                  controller: id,
                                  decoration: InputDecoration(
                                      labelText:
                                          tr(context, 'Teacher number'))),
                              const SizedBox(height: 14),
                              TextField(
                                  controller: password,
                                  obscureText: !show,
                                  decoration: InputDecoration(
                                      labelText: tr(context, 'Password'),
                                      suffixIcon: IconButton(
                                          tooltip: tr(context, 'Show password'),
                                          onPressed: () =>
                                              setState(() => show = !show),
                                          icon: Icon(show
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined)))),
                              CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: remember,
                                  onChanged: (v) =>
                                      setState(() => remember = v!),
                                  title: const LText('Remember me')),
                              if (error != null)
                                LText(error!,
                                    style: const TextStyle(color: Colors.red)),
                              FilledButton(
                                  onPressed: () async {
                                    if (!await repo.signIn(id.text.trim(),
                                            password.text, remember) &&
                                        mounted) {
                                      setState(() => error =
                                          'Check your teacher number and password.');
                                    }
                                  },
                                  child: const LText('Sign in')),
                              const SizedBox(height: 24),
                              const LText('Quick sign-in',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const LText('Access password: Learn123!'),
                              const SizedBox(height: 10),
                              for (final t in repo.teachers)
                                OutlinedButton(
                                    onPressed: () => repo.signIn(
                                        t.id, 'Learn123!', remember),
                                    child: LText('${t.name} • ${t.subject}')),
                              const SizedBox(height: 16),
                              const LText(
                                  'Accounts and class allocations are school-managed. This workspace stores changes on this device only.',
                                  style: TextStyle(fontSize: 12, height: 1.5)),
                              const SizedBox(height: 16),
                              const LText(LocalTeacherRepository.owner,
                                  style: TextStyle(fontSize: 11))
                            ]))))));
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
  final scaffold = GlobalKey<ScaffoldState>();
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
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final keys = destinations.keys.toList();
    return Scaffold(
        key: scaffold,
        appBar: AppBar(
            title: Row(children: [
              const CircleAvatar(
                  backgroundColor: Color(0xff2563eb),
                  child: Text('LD',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              const Expanded(
                  child: LText('Lucky Dube • Teachers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))
            ]),
            actions: const [TeacherLanguage()]),
        drawer: wide
            ? null
            : Drawer(
                child: SafeArea(
                    child: ListView(children: [
                const Padding(
                    padding: EdgeInsets.all(24),
                    child: LText('TEACHING WORKSPACE',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                for (var i = 0; i < keys.length; i++)
                  ListTile(
                      leading: Icon(icons[i]),
                      title: LText(destinations[keys[i]]!),
                      selected: widget.page == keys[i],
                      onTap: () {
                        Navigator.pop(context);
                        go(keys[i]);
                      })
              ]))),
        body: Row(children: [
          if (wide)
            SizedBox(
                width: 220,
                child: ListView(padding: const EdgeInsets.all(12), children: [
                  const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      child: LText('YOUR TEACHING DAY',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.5))),
                  for (var i = 0; i < keys.length; i++)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            selectedTileColor: const Color(0xffeaf3ff),
                            selectedColor: const Color(0xff2563eb),
                            selected: widget.page == keys[i],
                            leading: Icon(icons[i], size: 21),
                            title: LText(destinations[keys[i]]!,
                                style: const TextStyle(fontSize: 13)),
                            onTap: () => go(keys[i])))
                ])),
          Expanded(
              child:
                  ListView(padding: EdgeInsets.all(wide ? 32 : 16), children: [
            Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          content(),
                          const SizedBox(height: 30),
                          const LText(
                              'Optimal Growth Technologies SA • Changes are saved on this device. This workspace is not connected to school services.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xff64748b),
                                  height: 1.5))
                        ])))
          ]))
        ]),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: ['home', 'classes', 'marking', 'messages']
                        .contains(widget.page)
                    ? ['home', 'classes', 'marking', 'messages']
                        .indexOf(widget.page)
                    : 4,
                onDestinationSelected: (i) {
                  if (i == 4) {
                    scaffold.currentState!.openDrawer();
                  } else {
                    go(['home', 'classes', 'marking', 'messages'][i]);
                  }
                },
                destinations: [
                    for (var i = 0; i < 5; i++)
                      NavigationDestination(
                          icon: Icon([
                            Icons.home_outlined,
                            Icons.groups_outlined,
                            Icons.fact_check_outlined,
                            Icons.forum_outlined,
                            Icons.menu
                          ][i]),
                          label: tr(
                              context,
                              [
                                'Home',
                                'Classes',
                                'Marking',
                                'Messages',
                                'More'
                              ][i]))
                  ]));
  }

  Widget content() {
    switch (widget.page) {
      case 'home':
        return dashboard();
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

  Widget dashboard() {
    final metrics = <(String, String, String, IconData)>[
      (
        'Assigned classes',
        '${r.classes.length}',
        'classes',
        Icons.groups_outlined
      ),
      (
        'Learners',
        '${r.classes.fold<int>(0, (n, c) => n + r.roster(c.id).length)}',
        'classes',
        Icons.school_outlined
      ),
      ('To mark', '${r.pendingMarking}', 'marking', Icons.fact_check_outlined),
      (
        'Published lessons',
        '${r.ofKind('Lesson').where((l) => l.status == 'Published').length}',
        'planner',
        Icons.auto_stories_outlined
      ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeading('Good morning, ${r.teacher.name.split(' ').first} 👋',
          'Thursday, 26 November 2026 • Term 4 • ${r.teacher.subject}'),
      WelcomeBanner(onContinue: () => go('planner')),
      const SizedBox(height: 20),
      LayoutBuilder(
          builder: (context, box) =>
              Wrap(spacing: 12, runSpacing: 12, children: [
                for (final metric in metrics)
                  SizedBox(
                      width: box.maxWidth < 650
                          ? (box.maxWidth - 12) / 2
                          : (box.maxWidth - 36) / 4,
                      child: Card(
                          child: InkWell(
                              onTap: () => go(metric.$3),
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(metric.$4,
                                            color: const Color(0xff2563eb)),
                                        const SizedBox(height: 14),
                                        LText(metric.$1,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff64748b))),
                                        const SizedBox(height: 8),
                                        Text(metric.$2,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w800)),
                                      ])))))
              ])),
      const SizedBox(height: 22),
      Panel(
          'Today’s teaching',
          Column(children: [
            for (var i = 0; i < r.classes.length; i++)
              ActionTile(
                  '${r.teacher.subject} • ${r.classes[i].label}',
                  '${8 + i}:15–${9 + i}:00 • ${r.classes[i].room}',
                  Icons.schedule,
                  () => context.push('/class/${r.classes[i].id}'))
          ])),
      Panel(
          'Focus for today',
          Column(children: [
            ActionTile(
                'Review learner submissions',
                '${r.pendingMarking} awaiting feedback',
                Icons.fact_check_outlined,
                () => go('marking')),
            ActionTile(
                'Record attendance',
                'Complete a register for an assigned class',
                Icons.how_to_reg_outlined,
                () => go('attendance')),
            ActionTile(
                'Share a learning update',
                'Publish to one of your assigned classes',
                Icons.campaign_outlined,
                () => context.push('/new/Announcement')),
          ])),
    ]);
  }

  Widget classList() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('My classes',
            'Your assigned teaching groups • Read-only class allocations'),
        for (final c in r.classes)
          Card(
              child: ActionTile(
                  c.label,
                  '${r.teacher.subject} • ${r.roster(c.id).length} learners • ${c.room}',
                  Icons.groups_outlined,
                  () => context.push('/class/${c.id}')))
      ]);
  Widget searchControls(List<String> options) => Column(children: [
        TextField(
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: tr(context, 'Search your workspace')),
            onChanged: (v) => setState(() => search = v.toLowerCase())),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((o) => ChoiceChip(
                    label: LText(o),
                    selected: filter == o,
                    onSelected: (_) => setState(() => filter = o)))
                .toList()),
        const SizedBox(height: 20)
      ]);
  Widget recordList(String kind) {
    final data = r.ofKind(kind).where((item) =>
        item.title.toLowerCase().contains(search) &&
        (filter == 'All' || item.status == filter));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeading(
          {
            'Lesson': 'Lesson planner',
            'Resource': 'Learning resources',
            'Assignment': 'Assignments',
            'Announcement': 'Class announcements',
            'Rehearsal': 'Performing arts'
          }[kind]!,
          kind == 'Rehearsal'
              ? 'Rehearsals, creative preparation and educator feedback'
              : 'Create, review and publish for your assigned classes'),
      FilledButton.icon(
          onPressed: () => context.push('/new/$kind'),
          icon: const Icon(Icons.add),
          label: LText('Create $kind')),
      const SizedBox(height: 20),
      searchControls(['All', 'Draft', 'Published']),
      if (data.isEmpty)
        const Panel('Nothing here yet',
            LText('Create your first item or try a different filter.')),
      for (final item in data)
        Card(
            child: ActionTile(
                item.title,
                '${item.classId} • ${item.date} • ${item.status}',
                kind == 'Resource'
                    ? Icons.description_outlined
                    : Icons.auto_stories_outlined,
                () => context.push('/record/${Uri.encodeComponent(item.id)}')))
    ]);
  }

  Widget marking() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('Marking & feedback',
            'Review submitted work, save drafts and publish results'),
        searchControls(['All', 'Awaiting marking', 'Published']),
        for (final task in r.ofKind('Assignment'))
          Panel(
              task.title,
              Column(children: [
                for (final learner in r
                    .submissions(task)
                    .where((l) => l.name.toLowerCase().contains(search))
                    .where((l) =>
                        filter == 'All' ||
                        (r.markFor(task.id, l.id)?.published == true
                            ? filter == 'Published'
                            : filter == 'Awaiting marking')))
                  ActionTile(
                      learner.name,
                      '${task.classId} • ${r.markFor(task.id, learner.id)?.published == true ? 'Published' : 'Awaiting marking'}',
                      Icons.rate_review_outlined,
                      () => context.push(
                          '/mark/${Uri.encodeComponent(task.id)}/${learner.id}')),
                if (r.submissions(task).isEmpty)
                  const LText('No learner submissions yet.')
              ]))
      ]);
  Widget attendance() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeading('Attendance',
            'Complete and save a register for each teaching class'),
        for (final c in r.classes)
          Card(
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
            'Messages', 'Class conversations • Automated practice replies'),
        const Panel(
            'School-managed communication',
            LText(
                'Messages are saved on this device and are not delivered to learners or staff.')),
        for (final c in r.classes)
          Card(
              child: ActionTile(
                  '${c.label} • Class channel',
                  '${List<dynamic>.from(r.value('messages-${c.id}', [])).length} messages • Moderated group',
                  Icons.forum_outlined,
                  () => context.push('/conversation/${c.id}')))
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
        Card(
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
