# Teacher application scope

Implemented: separate teacher-only sign-in, assigned class boundaries, OG Vibes Staff-inspired dashboard, academic sidebar/profile toolbar, class portfolio, published agenda/deadlines, submission table, class-scoped full-screen search, filtered/paginated academic library and marking queue, rosters, lesson/resource/task/rehearsal/reminder/announcement editors, local text/image attachments, marking drafts and published results, progress calculations, dated attendance, class messaging, calendar agenda, arts preparation checklist, English/isiZulu UI, text size and confirmed profile-scoped reset.

No administration: no global user management, school setup, grade/class allocation editing, staff provisioning, permissions management, fees, payments or system-wide record control.

Local frontend boundaries: fixture submissions are available for the bundled assignments only. New assignments do not receive invented submissions. No live delivery, learner-app synchronisation, official report generation, push notifications, server-side authentication, PDF/video rendering or multi-device file storage is implemented. Teacher-created files are kept as base64 bytes in local browser preferences, capped to 2 MB per item.
