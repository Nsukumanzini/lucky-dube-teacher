// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/localization/app_language.dart';
import '../../data/teacher_repository.dart';
import '../../shared/components/staff_components.dart';
import 'teaching_queries.dart';
import 'submission_table.dart';

/// OG Vibes Staff's portfolio, agenda, quick actions and submission patterns,
/// adapted for school teachers and the existing local repository.
class TeachingDashboard extends StatelessWidget {
  final LocalTeacherRepository repository;
  final ValueChanged<String> navigate;
  const TeachingDashboard(
      {super.key, required this.repository, required this.navigate});
  @override
  Widget build(BuildContext context) {
    final r = repository;
    final deadlines = upcomingAssignments(r);
    final lessons = r
        .ofKind('Lesson')
        .where((x) =>
            x.status == 'Published' && x.date.compareTo(presentationDate) >= 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final metrics = [
      (
        'Learners',
        '${r.classes.fold<int>(0, (n, c) => n + r.roster(c.id).length)}',
        'Across your assigned classes',
        'classes',
        Icons.groups_outlined,
        blue
      ),
      (
        'Awaiting feedback',
        '${r.pendingMarking}',
        'Submitted learner work',
        'marking',
        Icons.fact_check_outlined,
        const Color(0xffaa7300)
      ),
      (
        'Upcoming assignments',
        '${deadlines.length}',
        'Published deadlines',
        'assignments',
        Icons.assignment_outlined,
        const Color(0xff8055d9)
      ),
      (
        'Published lessons',
        '${r.ofKind('Lesson').where((x) => x.status == 'Published').length}',
        'Ready for your classes',
        'planner',
        Icons.menu_book_outlined,
        const Color(0xff0891a3)
      ),
    ];
    Widget agenda(String title, String subtitle, List<TeachingRecord> items,
            String target, IconData icon) =>
        DashboardPanel(
            title: title,
            subtitle: subtitle,
            action: 'View all',
            onAction: () => navigate(target),
            child: Column(children: [
              if (items.isEmpty)
                const EmptyPanel('Nothing scheduled yet',
                    'Your published teaching plans will appear here.'),
              for (final item in items.take(3))
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tileColor: const Color(0xfff5f8fd),
                        contentPadding: const EdgeInsets.all(12),
                        leading: Icon(icon, color: blue, size: 21),
                        title: Text(item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        subtitle: Text('${item.classId} • ${item.date}',
                            style: const TextStyle(fontSize: 11, color: muted)),
                        onTap: () => context
                            .push('/record/${Uri.encodeComponent(item.id)}'))),
            ]));
    return DashboardReveal(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: const Color(0xffe7f1ff),
              border: Border.all(color: const Color(0xffcbdff8)),
              borderRadius: BorderRadius.circular(26)),
          child: LayoutBuilder(builder: (context, box) {
            final intro =
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.auto_awesome_outlined, size: 16, color: blue),
                SizedBox(width: 8),
                Expanded(
                    child: LText('TEACHER DASHBOARD',
                        style: TextStyle(
                            fontSize: 10,
                            color: blue,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5)))
              ]),
              const SizedBox(height: 18),
              LText('Good morning, ${r.teacher.name.split(' ').first}',
                  style: TextStyle(
                      fontSize: box.maxWidth < 550 ? 26 : 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: ink)),
              const SizedBox(height: 12),
              const LText('Plan with clarity. Teach with purpose.',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff315779))),
              const SizedBox(height: 10),
              const LText(
                  'Learner progress, deadlines and your teaching day in one focused workspace.',
                  style: TextStyle(
                      fontSize: 13, height: 1.7, color: Color(0xff526783))),
              const SizedBox(height: 20),
              FilledButton.icon(
                  onPressed: () => context.push('/new/Lesson'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const LText('Plan a lesson')),
            ]);
            final date = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .75),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LText('YOUR TEACHING DAY',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xff078394),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                      const SizedBox(height: 10),
                      const LText('Thursday, 26 November',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      LText('Term 4 • 2026 • ${r.teacher.subject}',
                          style: const TextStyle(fontSize: 12, color: muted)),
                      const SizedBox(height: 18),
                      LText('${r.classes.length} assigned classes',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: blue))
                    ]));
            if (box.maxWidth < 760) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [intro, const SizedBox(height: 22), date]);
            }
            return Row(children: [
              Expanded(flex: 6, child: intro),
              const SizedBox(width: 28),
              Expanded(flex: 4, child: date)
            ]);
          })),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (context, box) {
        final count = box.maxWidth >= 800 ? 4 : 2;
        return Wrap(spacing: 14, runSpacing: 14, children: [
          for (final m in metrics)
            SizedBox(
                width: (box.maxWidth - 14 * (count - 1)) / count,
                child: MetricCard(
                    title: m.$1,
                    value: m.$2,
                    note: m.$3,
                    icon: m.$5,
                    color: m.$6,
                    onTap: () => navigate(m.$4)))
        ]);
      }),
      const SizedBox(height: 22),
      DashboardColumns(
          leftFlex: 5,
          rightFlex: 4,
          left: DashboardPanel(
              title: 'Teaching portfolio',
              subtitle: 'Your assigned classes and published progress',
              action: 'My classes',
              onAction: () => navigate('classes'),
              child: Column(children: [
                for (final c in r.classes)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                          color: const Color(0xfff6f9fd),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => context.push('/class/${c.id}'),
                              child: Padding(
                                  padding: const EdgeInsets.all(17),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffe5efff),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          11)),
                                              child: const Icon(
                                                  Icons.menu_book_outlined,
                                                  color: blue,
                                                  size: 21)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(c.label,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800)),
                                                const SizedBox(height: 5),
                                                Text(
                                                    '${r.teacher.subject} • ${c.room}',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: muted))
                                              ])),
                                          Text('${r.roster(c.id).length}',
                                              style: const TextStyle(
                                                  fontSize: 23,
                                                  fontWeight: FontWeight.w800))
                                        ]),
                                        const SizedBox(height: 16),
                                        LText(
                                            r.average(c.id) == null
                                                ? 'No published results yet'
                                                : '${r.average(c.id)!.toStringAsFixed(1)}% class average',
                                            style: const TextStyle(
                                                fontSize: 11, color: muted)),
                                        if (r.average(c.id) != null) ...[
                                          const SizedBox(height: 8),
                                          Semantics(
                                              label:
                                                  '${c.label}: ${r.average(c.id)!.toStringAsFixed(1)}%',
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child:
                                                      LinearProgressIndicator(
                                                          value:
                                                              r.average(c.id)! /
                                                                  100,
                                                          minHeight: 6,
                                                          color: const Color(
                                                              0xff0891a3),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xffe1eaf4))))
                                        ],
                                      ]))))),
              ])),
          right: Column(children: [
            agenda('Teaching agenda', 'Your next published lessons', lessons,
                'planner', Icons.calendar_month_outlined),
            const SizedBox(height: 18),
            agenda('Assignment deadlines', 'Upcoming published class tasks',
                deadlines, 'assignments', Icons.assignment_outlined)
          ])),
      const SizedBox(height: 22),
      LayoutBuilder(
          builder: (context, box) =>
              Wrap(spacing: 14, runSpacing: 14, children: [
                for (final action in [
                  (
                    'Grade submissions',
                    'Review work and publish thoughtful feedback.',
                    Icons.fact_check_outlined,
                    'marking'
                  ),
                  (
                    'Take attendance',
                    'Complete a register for your assigned class.',
                    Icons.how_to_reg_outlined,
                    'attendance'
                  ),
                  (
                    'Message your classes',
                    'Continue a school-managed class conversation.',
                    Icons.forum_outlined,
                    'messages'
                  )
                ])
                  SizedBox(
                      width: box.maxWidth < 700
                          ? box.maxWidth
                          : (box.maxWidth - 28) / 3,
                      child: Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => navigate(action.$4),
                              child: Padding(
                                  padding: const EdgeInsets.all(21),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(action.$3, color: blue, size: 24),
                                        const SizedBox(height: 14),
                                        LText(action.$1,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 7),
                                        LText(action.$2,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: muted,
                                                height: 1.6)),
                                        const SizedBox(height: 18),
                                        const Row(children: [
                                          Expanded(
                                              child: LText('Open workspace',
                                                  style: TextStyle(
                                                      color: blue,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 11))),
                                          Icon(Icons.arrow_forward,
                                              size: 16, color: blue)
                                        ])
                                      ]))))),
              ])),
      const SizedBox(height: 22),
      DashboardPanel(
          title: 'Recent submissions',
          subtitle: 'Submitted learner work across your assigned classes',
          action: 'Open marking',
          onAction: () => navigate('marking'),
          child: SubmissionTable(
              entries: assignedSubmissions(r).take(5).toList())),
    ]));
  }
}
