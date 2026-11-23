# lucky-dube-teacher

**Lucky Dube — Teacher web application**

A separate Flutter web frontend owned by **Optimal Growth Technologies SA**. This application has teacher profiles only. There is no administration role, role selector, account provisioning, staff management, school configuration editor or learner-registration feature.

## Run

Requires Flutter stable (verified with Flutter 3.50.1 / Dart 3.14):

```sh
flutter pub get
flutter run -d chrome
```

Quick sign-in profiles:

| Number | Fictional teacher | Subject | Assigned classes |
|---|---|---|---|
| T1001 | Nolwazi Maseko | English | 8A, 9A, 10A |
| T1002 | Andile Dlamini | Mathematics | 8A, 9A |
| T1003 | Priya Khumalo | Creative Arts | 8A, 10A |

Password: **Learn123!**. Sign-in validates the teacher identity and password locally. Remember me controls session restoration. Language can be selected before sign-in and in the header. The teacher app uses the distinct storage key `lucky_dube_teacher_v1`, keeping its data separate from the learner app.

## OG Vibes Staff design foundation

The teacher workspace adapts the owner’s [OG Vibes Staff source](https://github.com/Nsukumanzini/og-vibes-staff): academic navigation, a personal teaching hero, metric cards, class portfolio, agenda/deadline panels, quick actions and a recent submission table. The academic library and marking queue support class/status filters, search and pagination. Full-screen workspace search stays within the signed-in teacher’s assigned classes. See `docs/DESIGN_SOURCE.md` for source mapping and preserved boundaries.

## Teacher workflows

- Dashboard: assigned classes, learner count, pending marking and published lessons, calculated from repository records.
- Classes: read-only allocations and rosters; learner progress includes published marks only.
- Lesson planner: create/edit objectives, structured teaching activities, dates and draft/published status.
- Resources: original notes and persistent local TXT/MD/PNG/JPG attachments with working text/image previews. Attachments are limited to 2 MB total per item. PDF/video preview is not offered.
- Assignments: create class tasks with instructions, due date and total marks. Bundled assignments include original fictional submissions. Newly created assignments start with no submissions.
- Marking: review responses, validate marks, save a marking draft and publish feedback/results locally. Published results update class progress; draft marks remain excluded.
- Attendance: choose date, record present/absent/late/excused status for every assigned learner, bulk-mark present and save a complete register.
- Communication: assigned-class channels with persistent messages and explicitly labelled automated practice replies.
- Calendar: selected-date agenda for the teacher's lessons, deadlines, rehearsals and personal reminders.
- Announcements: author targeted class updates; no school-wide administrative announcements.
- Performing arts: rehearsal schedules, preparation notes and persistent production checklists.
- Profile/settings: read-only teacher identity, English/isiZulu interface, text size, sign out and confirmed reset of the active teacher's local information.

## Important operating boundaries

No backend, API keys, external APIs, database service or push service is implemented. Data stays on the current browser/device; publishing does not send content, marks, attendance or messages to the separate learner app or to school staff. Opening this app on another device does not synchronise its data. Client-side teacher/class checks organise the local fixtures; they are not production authentication or server-side authorisation. Profiles are fictional, and no school endorsement is implied. Do not enter sensitive personal information.

UI translations are bundled locally in `lib/app/localization/zu.json`. Update the reviewable catalogue, run `python3 tool/generate_catalog.py`, then `dart format lib/app/localization/catalog.dart`. Teacher-authored lesson notes, feedback, filenames and message bodies retain their entered language. Have school-specific terminology reviewed by an isiZulu-speaking educator.

## Architecture

- `lib/app`: Material 3 light theme, GoRouter, framework/application localisation.
- `lib/data`: immutable teacher/class/learner/content/mark models, repository contract and SharedPreferences implementation.
- `lib/features`: adaptive workspace and full-screen editors, content details, marking, registers and conversations.
- `lib/shared/components`: responsive pages, cards, language switch and original locally painted artwork.
- Riverpod injects and observes the repository. Each teacher's records, marks, attendance, messages and checklist state use a teacher-prefixed key.

A future backend phase should implement server authentication and class permissions, typed asynchronous repository operations, uploaded file storage and shared teacher/learner events. Expand the existing TeacherRepository contract to cover the remaining local helper operations, replace the provider implementation and retain the teacher-facing screens. The administration application should remain a separate project and role surface.

## Verification and build

```sh
flutter pub get
dart format .
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8080 --directory build/web
```

The release bundles rendering resources, fonts and original assets locally. A browser needs an initial load from the host; there is no external dependency for application operations after its resources are loaded. No service-worker installation/offline-reload guarantee is claimed.

See `docs/VALIDATION.md` for actual results. Only web was targeted for this application. No native build success is claimed.

## Hosted teacher workspace

Vercel project: `lucky-dube-teachers`, separate from the learner project. Deployment is a static Flutter release uploaded directly through the connected Vercel API. The teacher source is maintained independently of the learner repository. Source is also supplied in `lucky_dube_teacher_source.zip`.

Source repository: https://github.com/Nsukumanzini/lucky-dube-teacher (public).
