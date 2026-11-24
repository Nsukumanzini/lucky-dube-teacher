import 'dart:convert';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../data/teacher_repository.dart';
import '../app/localization/app_language.dart';
import '../shared/components/teacher_components.dart';
import '../shared/components/premium_surface.dart';

Widget unavailable() => const TeacherPage(
    title: 'Content unavailable',
    child: LText('This content is not assigned to your teaching profile.'));

class ClassScreen extends ConsumerWidget {
  final String id;
  const ClassScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(teacherRepositoryProvider);
    if (!r.classes.any((c) => c.id == id)) return unavailable();
    final c = r.classes.firstWhere((c) => c.id == id);
    final tasks = r.ofKind('Assignment').where((t) => t.classId == id).toList();
    return TeacherPage(
        title: c.label,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeading(c.label,
              '${r.teacher.subject} • ${c.room} • ${r.roster(id).length} learners'),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
                onPressed: () => context.push('/attendance/$id'),
                icon: const Icon(Icons.how_to_reg_outlined),
                label: const LText('Take attendance')),
            OutlinedButton.icon(
                onPressed: () => context.push('/conversation/$id'),
                icon: const Icon(Icons.forum_outlined),
                label: const LText('Class conversation'))
          ]),
          const SizedBox(height: 24),
          Panel(
              'Learner roster & progress',
              Column(children: [
                for (final l in r.roster(id))
                  Builder(builder: (context) {
                    final scores = r.marks
                        .where((m) =>
                            m.learnerId == l.id &&
                            m.published &&
                            tasks.any((t) => t.id == m.taskId))
                        .toList();
                    return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                            backgroundColor: const Color(0xffeaf3ff),
                            child: Text(
                                l.name
                                    .split(' ')
                                    .map((s) => s[0])
                                    .take(2)
                                    .join(),
                                style: const TextStyle(
                                    color: Color(0xff2563eb), fontSize: 12))),
                        title: Text(l.name),
                        subtitle: LText(
                            '${l.id} • ${scores.length} published results'),
                        trailing: scores.isEmpty
                            ? const LText('—')
                            : Text(
                                '${(scores.map((s) => s.mark / r.record(s.taskId).maxMarks * 100).reduce((a, b) => a + b) / scores.length).round()}%'));
                  })
              ])),
          Panel(
              'Class learning',
              Column(children: [
                for (final record
                    in r.records.where((record) => record.classId == id))
                  ActionTile(
                      record.title,
                      '${record.kind} • ${record.status}',
                      Icons.auto_stories_outlined,
                      () => context
                          .push('/record/${Uri.encodeComponent(record.id)}'))
              ]))
        ]));
  }
}

class RecordEditor extends ConsumerStatefulWidget {
  final String? kind, recordId;
  const RecordEditor({super.key, this.kind, this.recordId});
  @override
  ConsumerState<RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends ConsumerState<RecordEditor> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      body = TextEditingController(),
      marks = TextEditingController(text: '50');
  String classId = '', kind = 'Lesson', date = '2026-11-27';
  bool invalid = false, busy = false;
  String? id;
  Map<String, String> attachments = {};
  @override
  void initState() {
    super.initState();
    final r = ref.read(teacherRepositoryProvider);
    classId = r.classes.first.id;
    kind = widget.kind ?? 'Lesson';
    if (widget.recordId != null) {
      final matches = r.records.where((x) => x.id == widget.recordId);
      if (matches.isEmpty) {
        invalid = true;
      } else {
        final record = matches.first;
        id = record.id;
        kind = record.kind;
        classId = record.classId;
        date = record.date;
        title.text = record.title;
        body.text = record.body;
        marks.text = record.maxMarks.toString();
        attachments = Map.of(record.attachments);
      }
    }
    if (![
      'Lesson',
      'Assignment',
      'Resource',
      'Announcement',
      'Rehearsal',
      'Reminder'
    ].contains(kind)) {
      invalid = true;
    }
  }

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    marks.dispose();
    super.dispose();
  }

  Future<void> save(String status) async {
    if (!form.currentState!.validate()) return;
    final r = ref.read(teacherRepositoryProvider);
    setState(() => busy = true);
    try {
      final record = TeachingRecord(
          id: id ?? '${r.teacher.id}-${DateTime.now().microsecondsSinceEpoch}',
          teacherId: r.teacher.id,
          classId: classId,
          kind: kind,
          title: title.text.trim(),
          body: body.text.trim(),
          date: date,
          status: status,
          maxMarks: int.parse(marks.text),
          attachments: attachments);
      await r.saveRecord(record);
      if (mounted) {
        savedMessage(
            context,
            status == 'Published'
                ? 'Published on this device'
                : 'Draft saved locally');
        context.replace('/record/${Uri.encodeComponent(record.id)}');
      }
    } on ArgumentError {
      if (mounted) savedMessage(context, 'Check all fields before saving.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> attach() async {
    final files = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'png', 'jpg', 'jpeg'],
        withData: true,
        allowMultiple: true);
    if (files == null || !mounted) return;
    final next = Map<String, String>.from(attachments);
    for (final file in files.files) {
      if (file.bytes == null) continue;
      next[file.name] = base64Encode(file.bytes!);
    }
    if (next.values.fold<int>(0, (n, b) => n + base64Decode(b).length) >
        2 * 1024 * 1024) {
      savedMessage(context, 'Attachments must total 2 MB or less.');
      return;
    }
    setState(() => attachments = next);
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(teacherRepositoryProvider);
    if (invalid) return unavailable();
    return TeacherPage(
        title: '${id == null ? 'Create' : 'Edit'} $kind',
        actions: [
          TextButton(
              onPressed: busy ? null : () => save('Draft'),
              child: const LText('Save draft')),
          FilledButton.icon(
              onPressed: busy ? null : () => save('Published'),
              icon: const Icon(Icons.publish_outlined),
              label: LText(busy ? 'Saving…' : 'Publish'))
        ],
        child: Form(
            key: form,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              PageHeading('${id == null ? 'Create' : 'Edit'} $kind',
                  'Only your assigned classes are available'),
              DropdownButtonFormField<String>(
                  initialValue: classId,
                  isExpanded: true,
                  decoration:
                      InputDecoration(labelText: tr(context, 'Teaching class')),
                  items: r.classes
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: LText(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => classId = v!)),
              const SizedBox(height: 18),
              TextFormField(
                  controller: title,
                  decoration: InputDecoration(labelText: tr(context, 'Title')),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? tr(context, 'Enter a title')
                      : null),
              const SizedBox(height: 18),
              TextFormField(
                  controller: body,
                  minLines: 7,
                  maxLines: 15,
                  decoration: InputDecoration(
                      labelText: tr(
                          context,
                          kind == 'Assignment'
                              ? 'Instructions & submission requirements'
                              : kind == 'Lesson'
                                  ? 'Objectives, activities & reflection'
                                  : 'Content & preparation notes'),
                      alignLabelWithHint: true),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? tr(context, 'Enter the content')
                      : null),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(date),
                        firstDate: DateTime(2026),
                        lastDate: DateTime(2028));
                    if (selected != null) {
                      setState(() =>
                          date = selected.toIso8601String().substring(0, 10));
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: LText(
                      '${kind == 'Assignment' ? 'Due date' : 'Activity date'}: $date')),
              if (kind == 'Assignment') ...[
                const SizedBox(height: 18),
                TextFormField(
                    controller: marks,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: tr(context, 'Total marks')),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1 || n > 1000
                          ? tr(context, 'Enter marks from 1 to 1000')
                          : null;
                    })
              ],
              const SizedBox(height: 24),
              Panel(
                  'Attachments',
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LText(
                            'Notes and images • TXT, MD, PNG, JPG • 2 MB total • Stored on this device'),
                        const SizedBox(height: 12),
                        for (final name in attachments.keys)
                          ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(name),
                              leading:
                                  const Icon(Icons.insert_drive_file_outlined),
                              trailing: IconButton(
                                  tooltip: tr(context, 'Remove attachment'),
                                  onPressed: () =>
                                      setState(() => attachments.remove(name)),
                                  icon: const Icon(Icons.close))),
                        OutlinedButton.icon(
                            onPressed: busy ? null : attach,
                            icon: const Icon(Icons.attach_file),
                            label: const LText('Choose local files'))
                      ])),
              const LText(
                  'Publishing updates this teacher workspace only. No data is sent to another app or school service.',
                  style: TextStyle(fontSize: 12, height: 1.6))
            ])));
  }
}

class RecordScreen extends ConsumerWidget {
  final String id;
  const RecordScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(teacherRepositoryProvider);
    final found = r.records.where((x) => x.id == id);
    if (found.isEmpty) return unavailable();
    final record = found.first;
    return TeacherPage(
        title: record.title,
        actions: [
          OutlinedButton.icon(
              onPressed: () => context.push('/edit/${Uri.encodeComponent(id)}'),
              icon: const Icon(Icons.edit_outlined),
              label: const LText('Edit content'))
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip(label: LText(record.kind)),
            Chip(label: Text(record.classId)),
            Chip(label: LText(record.status))
          ]),
          const SizedBox(height: 22),
          PageHeading(record.title,
              '${record.date} • ${r.teacher.subject}${record.kind == 'Assignment' ? ' • ${record.maxMarks} marks' : ''}'),
          Panel(
              record.kind == 'Lesson' ? 'Lesson plan' : 'Instructions & notes',
              SelectableText(record.body, style: const TextStyle(height: 1.8))),
          for (final attachment in record.attachments.entries)
            Panel(
                attachment.key,
                RegExp(r'\.(png|jpe?g)$', caseSensitive: false)
                        .hasMatch(attachment.key)
                    ? Image.memory(base64Decode(attachment.value),
                        height: 280,
                        errorBuilder: (c, e, s) =>
                            const LText('This image could not be previewed.'))
                    : SelectableText(utf8.decode(base64Decode(attachment.value),
                        allowMalformed: true))),
          if (record.kind == 'Assignment')
            Panel(
                'Submissions',
                Column(children: [
                  for (final learner in r.submissions(record))
                    ActionTile(
                        learner.name,
                        '${r.markFor(record.id, learner.id)?.published == true ? 'Published' : 'Awaiting marking'} • ${learner.id}',
                        Icons.assignment_turned_in_outlined,
                        () => context.push(
                            '/mark/${Uri.encodeComponent(id)}/${learner.id}')),
                  if (r.submissions(record).isEmpty)
                    const LText('No learner submissions yet.')
                ])),
          if (record.kind == 'Rehearsal')
            Panel(
                'Performance preparation',
                Column(children: [
                  for (final item in [
                    'Venue prepared',
                    'Equipment checked',
                    'Warm-up planned',
                    'Learner feedback recorded'
                  ])
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: r.value('check-$id-$item', false) as bool,
                        onChanged: (v) => r.put('check-$id-$item', v),
                        title: LText(item)),
                  TextButton(
                      onPressed: () =>
                          context.push('/attendance/${record.classId}'),
                      child: const LText('Open attendance register'))
                ]))
        ]));
  }
}

class MarkingScreen extends ConsumerStatefulWidget {
  final String taskId, learnerId;
  const MarkingScreen(
      {super.key, required this.taskId, required this.learnerId});
  @override
  ConsumerState<MarkingScreen> createState() => _MarkingScreenState();
}

class _MarkingScreenState extends ConsumerState<MarkingScreen> {
  final form = GlobalKey<FormState>(),
      score = TextEditingController(),
      feedback = TextEditingController();
  bool invalid = false, busy = false;
  late TeachingRecord task;
  late Learner learner;
  @override
  void initState() {
    super.initState();
    final r = ref.read(teacherRepositoryProvider);
    final tasks = r.ofKind('Assignment').where((x) => x.id == widget.taskId);
    if (tasks.isEmpty) {
      invalid = true;
      return;
    }
    task = tasks.first;
    final learners = r.submissions(task).where((l) => l.id == widget.learnerId);
    if (learners.isEmpty) {
      invalid = true;
      return;
    }
    learner = learners.first;
    final mark = r.markFor(task.id, learner.id);
    if (mark != null) {
      score.text = '${mark.mark}';
      feedback.text = mark.feedback;
    }
  }

  @override
  void dispose() {
    score.dispose();
    feedback.dispose();
    super.dispose();
  }

  Future<void> save(bool published) async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await ref.read(teacherRepositoryProvider).saveMark(MarkRecord(task.id,
          learner.id, int.parse(score.text), feedback.text.trim(), published));
      if (mounted) {
        savedMessage(
            context,
            published
                ? 'Result published on this device'
                : 'Marking draft saved');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(teacherRepositoryProvider);
    if (invalid) return unavailable();
    final existing = r.markFor(task.id, learner.id);
    return TeacherPage(
        title: 'Mark submission',
        actions: [
          if (existing?.published != true)
            TextButton(
                onPressed: busy ? null : () => save(false),
                child: const LText('Save marking draft')),
          FilledButton(
              onPressed: busy ? null : () => save(true),
              child: LText(existing?.published == true
                  ? 'Update published result'
                  : 'Publish result'))
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeading(
              learner.name, '${learner.id} • ${task.classId} • ${task.title}'),
          Panel(
              'Learner response',
              SelectableText(r.responseFor(learner),
                  style: const TextStyle(height: 1.8))),
          Form(
              key: form,
              child: Panel(
                  'Mark & educator feedback',
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText('Maximum: ${task.maxMarks} marks'),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: score,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: tr(context, 'Mark obtained')),
                            validator: (value) {
                              final mark = int.tryParse(value ?? '');
                              return mark == null ||
                                      mark < 0 ||
                                      mark > task.maxMarks
                                  ? tr(context,
                                      'Enter a mark within the available total')
                                  : null;
                            }),
                        const SizedBox(height: 18),
                        TextFormField(
                            controller: feedback,
                            minLines: 5,
                            maxLines: 10,
                            decoration: InputDecoration(
                                labelText: tr(context, 'Constructive feedback'),
                                alignLabelWithHint: true),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? tr(context, 'Enter feedback before saving')
                                : null),
                        const SizedBox(height: 16),
                        LText(existing?.published == true
                            ? 'Published • Included in learner progress'
                            : 'Draft • Not included in published results'),
                        const SizedBox(height: 10),
                        const LText(
                            'Publishing updates local results only. No result is sent to the learner app.',
                            style: TextStyle(fontSize: 12, height: 1.6))
                      ])))
        ]));
  }
}

class AttendanceScreen extends ConsumerStatefulWidget {
  final String classId;
  const AttendanceScreen({super.key, required this.classId});
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String date = '2026-11-26';
  Map<String, String> statuses = {};
  bool invalid = false;
  @override
  void initState() {
    super.initState();
    final r = ref.read(teacherRepositoryProvider);
    invalid = !r.classes.any((c) => c.id == widget.classId);
    if (!invalid) statuses = r.attendance(widget.classId, date);
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(teacherRepositoryProvider);
    if (invalid) return unavailable();
    return TeacherPage(
        title: '${widget.classId} • Attendance',
        actions: [
          FilledButton.icon(
              onPressed: () async {
                try {
                  await r.saveAttendance(widget.classId, date, statuses);
                  if (context.mounted) {
                    savedMessage(context, 'Attendance saved on this device');
                  }
                } on ArgumentError {
                  if (context.mounted) {
                    savedMessage(context, 'Choose a status for every learner.');
                  }
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const LText('Save register'))
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageHeading('Class attendance',
              'Record every learner before saving the register'),
          Wrap(spacing: 10, runSpacing: 10, children: [
            OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(date),
                      firstDate: DateTime(2026),
                      lastDate: DateTime(2028));
                  if (selected != null) {
                    setState(() {
                      date = selected.toIso8601String().substring(0, 10);
                      statuses = r.attendance(widget.classId, date);
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(date)),
            TextButton(
                onPressed: () => setState(() => statuses = {
                      for (final learner in r.roster(widget.classId))
                        learner.id: 'Present'
                    }),
                child: const LText('Mark all present'))
          ]),
          const SizedBox(height: 20),
          for (final learner in r.roster(widget.classId))
            LiquidGlassSurface(
                padding: EdgeInsets.zero,
                child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(learner.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(learner.id,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xff64748b)))
                          ])),
                      const SizedBox(width: 12),
                      SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                              key: ValueKey(
                                  '$date-${learner.id}-${statuses[learner.id]}'),
                              initialValue: statuses[learner.id],
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: tr(context, 'Status')),
                              items: ['Present', 'Absent', 'Late', 'Excused']
                                  .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: LText(s,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (s) =>
                                  setState(() => statuses[learner.id] = s!)))
                    ]))),
          const SizedBox(height: 16),
          LText(
              '${statuses.length} / ${r.roster(widget.classId).length} learners recorded')
        ]));
  }
}

class ConversationScreen extends ConsumerStatefulWidget {
  final String classId;
  const ConversationScreen({super.key, required this.classId});
  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    input.clear();
    await ref.read(teacherRepositoryProvider).sendMessage(widget.classId, text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(teacherRepositoryProvider);
    if (!r.classes.any((c) => c.id == widget.classId)) return unavailable();
    final messages =
        List<dynamic>.from(r.value('messages-${widget.classId}', []));
    return TeacherPage(
        title: '${widget.classId} • Class conversation',
        scroll: false,
        child: Column(children: [
          const LText(
              'Moderated class channel • Messages stay on this device. Responses are automated practice replies.',
              style: TextStyle(
                  fontSize: 12, color: Color(0xff64748b), height: 1.5)),
          const SizedBox(height: 16),
          Expanded(
              child: ListView(controller: scroll, children: [
            const Center(child: Chip(label: Text('26 November 2026'))),
            const SizedBox(height: 18),
            if (messages.isEmpty)
              const Panel(
                  'Keep learning connected',
                  LText(
                      'Share a reminder, answer a question or encourage your class.')),
            for (final raw in messages)
              Builder(builder: (context) {
                final m = Map<String, dynamic>.from(raw);
                final sent = m['sender'] == 'You';
                return Align(
                    alignment:
                        sent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color:
                                sent ? const Color(0xff2563eb) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: sent
                                    ? const Color(0xff2563eb)
                                    : const Color(0xffe2e8f0))),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LText(m['sender'],
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: sent
                                          ? Colors.white70
                                          : const Color(0xff64748b))),
                              const SizedBox(height: 8),
                              Text(m['body'],
                                  style: TextStyle(
                                      color: sent
                                          ? Colors.white
                                          : const Color(0xff22334b),
                                      height: 1.6)),
                              const SizedBox(height: 8),
                              LText('${m['time']} • Saved locally',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: sent
                                          ? Colors.white70
                                          : const Color(0xff64748b)))
                            ])));
              })
          ])),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => send(),
                    decoration: InputDecoration(
                        labelText: tr(context, 'Class message')))),
            const SizedBox(width: 10),
            IconButton.filled(
                tooltip: tr(context, 'Send message'),
                onPressed: send,
                icon: const Icon(Icons.send_rounded))
          ])
        ]));
  }
}
