// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/localization/app_language.dart';
import '../../data/teacher_repository.dart';
import '../../shared/components/teacher_components.dart';
import '../../shared/components/staff_components.dart';
import '../../shared/components/premium_surface.dart';
import 'teaching_queries.dart';
import 'submission_table.dart';

class TeachingLibrary extends StatefulWidget {
  final LocalTeacherRepository repository;
  final String kind;
  const TeachingLibrary(
      {super.key, required this.repository, required this.kind});
  @override
  State<TeachingLibrary> createState() => _TeachingLibraryState();
}

class _TeachingLibraryState extends State<TeachingLibrary> {
  String query = '', status = 'All', classId = 'All';
  bool ascending = true;
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final r = widget.repository;
    final kind = widget.kind;
    final all = r.ofKind(kind);
    final filtered = all
        .where((x) =>
            '${x.title} ${x.body} ${x.classId}'
                .toLowerCase()
                .contains(query.toLowerCase()) &&
            (status == 'All' || x.status == status) &&
            (classId == 'All' || x.classId == classId))
        .toList()
      ..sort((a, b) =>
          ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    final pages = (filtered.length / 6).ceil().clamp(1, 999999);
    final current = page.clamp(0, pages - 1);
    final visible = filtered.skip(current * 6).take(6).toList();
    final title = {
      'Lesson': 'Lesson planner',
      'Resource': 'Academic library',
      'Assignment': 'Assignments',
      'Announcement': 'Class announcements',
      'Rehearsal': 'Performing arts'
    }[kind]!;
    final symbol = switch (kind) {
      'Lesson' => Icons.auto_stories_outlined,
      'Resource' => Icons.folder_outlined,
      'Assignment' => Icons.assignment_outlined,
      'Rehearsal' => Icons.theater_comedy_outlined,
      _ => Icons.campaign_outlined
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeading(title,
          'Create, organise and share teaching content with your assigned classes.'),
      Wrap(spacing: 10, runSpacing: 10, children: [
        FilledButton.icon(
            onPressed: () => context.push('/new/$kind'),
            icon: const Icon(Icons.add, size: 18),
            label: LText('Create $kind')),
        StatusPill(
            '${all.where((x) => x.status == 'Published').length} Published'),
        StatusPill('${all.where((x) => x.status == 'Draft').length} Draft')
      ]),
      const SizedBox(height: 22),
      DashboardPanel(
          title: 'Content workspace',
          subtitle:
              'Filter by class and status, then open an item to continue.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: tr(context, 'Search teaching content')),
                onChanged: (value) => setState(() {
                      query = value;
                      page = 0;
                    })),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final value in ['All', 'Draft', 'Published'])
                ChoiceChip(
                    label: LText(value),
                    selected: status == value,
                    onSelected: (_) => setState(() {
                          status = value;
                          page = 0;
                        })),
              OutlinedButton.icon(
                  onPressed: () => setState(() {
                        ascending = !ascending;
                        page = 0;
                      }),
                  icon: Icon(
                      ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16),
                  label: LText(
                      ascending ? 'Date: earliest first' : 'Date: latest first',
                      style: const TextStyle(fontSize: 11)))
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final value in ['All', ...r.classes.map((c) => c.id)])
                ChoiceChip(
                    label: LText(value == 'All' ? 'All classes' : value),
                    selected: classId == value,
                    onSelected: (_) => setState(() {
                          classId = value;
                          page = 0;
                        }))
            ]),
          ])),
      const SizedBox(height: 20),
      if (visible.isEmpty)
        const DashboardPanel(
            title: 'Nothing here yet',
            subtitle: 'Try another filter or create a new item.',
            child: EmptyPanel('No matching content',
                'Your teaching materials will appear here.')),
      LayoutBuilder(builder: (context, box) {
        final columns = box.maxWidth >= 1000
            ? 3
            : box.maxWidth >= 620
                ? 2
                : 1;
        return Wrap(spacing: 16, runSpacing: 16, children: [
          for (final item in visible)
            SizedBox(
                width: (box.maxWidth - 16 * (columns - 1)) / columns,
                child: LiquidGlassSurface(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context
                            .push('/record/${Uri.encodeComponent(item.id)}'),
                        child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffeaf2ff),
                                            borderRadius:
                                                BorderRadius.circular(13)),
                                        child: Icon(symbol,
                                            color: blue, size: 23)),
                                    const Spacer(),
                                    Flexible(child: StatusPill(item.status))
                                  ]),
                                  const SizedBox(height: 20),
                                  Text(item.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          height: 1.4)),
                                  const SizedBox(height: 10),
                                  Text(item.body.replaceAll('\n', ' '),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.7,
                                          color: muted)),
                                  const SizedBox(height: 20),
                                  Wrap(spacing: 10, runSpacing: 7, children: [
                                    Text(item.classId,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: blue,
                                            fontWeight: FontWeight.w700)),
                                    Text(item.date,
                                        style: const TextStyle(
                                            fontSize: 11, color: muted)),
                                    if (kind == 'Assignment')
                                      LText('${item.maxMarks} marks',
                                          style: const TextStyle(
                                              fontSize: 11, color: muted)),
                                    if (item.attachments.isNotEmpty)
                                      LText(
                                          '${item.attachments.length} attachments',
                                          style: const TextStyle(
                                              fontSize: 11, color: muted))
                                  ]),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Row(children: [
                                    Expanded(
                                        child: LText('Open item',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: blue,
                                                fontWeight: FontWeight.w700))),
                                    Icon(Icons.arrow_forward,
                                        size: 17, color: blue)
                                  ]),
                                ])))))
        ]);
      }),
      const SizedBox(height: 18),
      DirectoryPager(
          current: current,
          pages: pages,
          total: filtered.length,
          onPage: (value) => setState(() => page = value)),
    ]);
  }
}

class DirectoryPager extends StatelessWidget {
  final int current, pages, total;
  final ValueChanged<int> onPage;
  const DirectoryPager(
      {super.key,
      required this.current,
      required this.pages,
      required this.total,
      required this.onPage});
  @override
  Widget build(BuildContext context) => Wrap(
          spacing: 18,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LText(total == 1 ? '1 item' : '$total items',
                style: const TextStyle(fontSize: 12, color: muted)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton.outlined(
                  tooltip: tr(context, 'Previous page'),
                  onPressed: current == 0 ? null : () => onPage(current - 1),
                  icon: const Icon(Icons.chevron_left, size: 18)),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('${current + 1} / $pages',
                      style: const TextStyle(fontSize: 12, color: muted))),
              IconButton.outlined(
                  tooltip: tr(context, 'Next page'),
                  onPressed:
                      current + 1 >= pages ? null : () => onPage(current + 1),
                  icon: const Icon(Icons.chevron_right, size: 18))
            ]),
          ]);
}

class MarkingQueue extends StatefulWidget {
  final LocalTeacherRepository repository;
  const MarkingQueue({super.key, required this.repository});
  @override
  State<MarkingQueue> createState() => _MarkingQueueState();
}

class _MarkingQueueState extends State<MarkingQueue> {
  String query = '', status = 'All', classId = 'All';
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final r = widget.repository;
    final submissions = assignedSubmissions(r);
    final filtered = submissions
        .where((e) =>
            '${e.learner.name} ${e.learner.id} ${e.task.title}'
                .toLowerCase()
                .contains(query.toLowerCase()) &&
            (status == 'All' || e.status == status) &&
            (classId == 'All' || e.task.classId == classId))
        .toList();
    final pages = (filtered.length / 8).ceil().clamp(1, 999999);
    final current = page.clamp(0, pages - 1);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeading('Marking & feedback',
          'Review submitted work, save drafts and publish results'),
      Wrap(spacing: 10, runSpacing: 10, children: [
        StatusPill('${r.pendingMarking} Awaiting marking'),
        StatusPill(
            '${submissions.where((e) => e.mark?.published == true).length} Published')
      ]),
      const SizedBox(height: 20),
      DashboardPanel(
          title: 'Submission workspace',
          subtitle: 'Open a learner submission for full-screen marking.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: tr(context, 'Search learner or assignment')),
                onChanged: (value) => setState(() {
                      query = value;
                      page = 0;
                    })),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final value in ['All', 'Awaiting marking', 'Published'])
                ChoiceChip(
                    label: LText(value),
                    selected: status == value,
                    onSelected: (_) => setState(() {
                          status = value;
                          page = 0;
                        }))
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final value in ['All', ...r.classes.map((c) => c.id)])
                ChoiceChip(
                    label: LText(value == 'All' ? 'All classes' : value),
                    selected: classId == value,
                    onSelected: (_) => setState(() {
                          classId = value;
                          page = 0;
                        }))
            ]),
            const SizedBox(height: 20),
            SubmissionTable(
                entries: filtered.skip(current * 8).take(8).toList()),
            const SizedBox(height: 18),
            DirectoryPager(
                current: current,
                pages: pages,
                total: filtered.length,
                onPage: (value) => setState(() => page = value)),
          ])),
    ]);
  }
}
