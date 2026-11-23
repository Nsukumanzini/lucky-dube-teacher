import '../../data/teacher_repository.dart';

const presentationDate = '2026-11-26';

class SubmissionEntry {
  final TeachingRecord task;
  final Learner learner;
  final MarkRecord? mark;
  const SubmissionEntry(this.task, this.learner, this.mark);
  String get status =>
      mark?.published == true ? 'Published' : 'Awaiting marking';
}

List<SubmissionEntry> assignedSubmissions(LocalTeacherRepository r) => [
      for (final task in r.ofKind('Assignment'))
        for (final learner in r.submissions(task))
          SubmissionEntry(task, learner, r.markFor(task.id, learner.id)),
    ];

List<TeachingRecord> upcomingAssignments(LocalTeacherRepository r) => r
    .ofKind('Assignment')
    .where((x) =>
        x.status == 'Published' && x.date.compareTo(presentationDate) >= 0)
    .toList()
  ..sort((a, b) => a.date.compareTo(b.date));
