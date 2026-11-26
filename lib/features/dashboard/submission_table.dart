// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/localization/app_language.dart';
import '../../shared/components/staff_components.dart';
import '../../shared/components/premium_surface.dart';
import 'teaching_queries.dart';

/// Responsive, actionable adaptation of OG Vibes Staff's recent activity table.
class SubmissionTable extends StatelessWidget {
  final List<SubmissionEntry> entries;
  const SubmissionTable({super.key, required this.entries});
  @override
  Widget build(BuildContext context) {
    void open(SubmissionEntry entry) => context.push(
        '/mark/${Uri.encodeComponent(entry.task.id)}/${entry.learner.id}');
    if (entries.isEmpty) {
      return const EmptyPanel(
          'No matching submissions', 'New submitted work will appear here.');
    }
    return LayoutBuilder(builder: (context, box) {
      if (box.maxWidth < 650) {
        return Column(children: [
          for (final e in entries)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LiquidGlassSurface(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => open(e),
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.learner.name,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 7),
                                  Text('${e.task.classId} • ${e.task.title}',
                                      style: const TextStyle(
                                          color: muted,
                                          fontSize: 11,
                                          height: 1.6)),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Flexible(child: StatusPill(e.status)),
                                    const Spacer(),
                                    const Icon(Icons.arrow_forward,
                                        size: 18, color: blue)
                                  ]),
                                ])))))
        ]);
      }
      Widget cell(String text, int flex, {bool strong = false}) => Expanded(
          flex: flex,
          child: Text(text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  color: strong ? ink : muted,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.normal)));
      return Column(children: [
        Container(
            padding: const EdgeInsets.all(13),
            color: const Color(0xfff6f9fc),
            child: Row(children: [
              for (final c in [
                ('Learner', 4),
                ('Homework', 5),
                ('Class', 2),
                ('Status', 4)
              ])
                Expanded(
                    flex: c.$2,
                    child: LText(c.$1,
                        style: const TextStyle(
                            fontSize: 10,
                            color: muted,
                            fontWeight: FontWeight.w700))),
              const SizedBox(width: 28)
            ])),
        for (final e in entries)
          InkWell(
              onTap: () => open(e),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 13),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: line))),
                  child: Row(children: [
                    cell(e.learner.name, 4, strong: true),
                    cell(e.task.title, 5),
                    cell(e.task.classId, 2),
                    Expanded(
                        flex: 4,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: StatusPill(e.status))),
                    const SizedBox(
                        width: 28,
                        child: Icon(Icons.chevron_right, size: 18, color: blue))
                  ]))),
      ]);
    });
  }
}
