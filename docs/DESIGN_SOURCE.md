# OG Vibes Staff source adaptation

Source: https://github.com/Nsukumanzini/og-vibes-staff
Inspected revision: `b088885c83f30863bb98117c50e53422ef362bfb`.

The owner requested use of this source for Lucky Dube's separate teacher application. The source repository is unchanged. The following Next.js/React patterns were adapted into Flutter:

| Source pattern | Lucky Dube adaptation |
| --- | --- |
| `components/dashboard/sidebar.tsx` | Academic navigation with icon tiles, adaptive drawer and mobile primary destinations |
| `components/dashboard/topbar.tsx` | Subject context, page title, search, language control and teacher identity |
| `app/dashboard/page.tsx` | Personal teaching hero, four repository-derived metrics, class portfolio, published lesson agenda and assignment deadlines |
| Dashboard quick-action cards | Full-screen grading, assigned-class attendance and moderated class conversations |
| `components/dashboard/recent-activity-table.tsx` | Responsive, actionable learner submission table with published/awaiting-marking status |
| Academic library and assessment workspaces | Filtered content cards and paginated marking queue with class scopes, search and status filters |
| Professional academic theme | Light slate surfaces with restrained blue, cyan, amber and violet accents; short reduced-motion-aware entrance animation |

Implementation: `lib/features/dashboard/`, `lib/shared/components/teacher_shell.dart` and `lib/shared/components/staff_components.dart`. Full-screen search covers only the authenticated teacher's records and allocated-class rosters. Existing editors, original local attachments, feedback publishing, attendance, conversations and language preferences remain connected to the original local repository and storage key `lucky_dube_teacher_v1`.

No source backend, Supabase, live classes, external keys, college-specific ICASS structures, account invitations or administration role was copied or connected. Only this separate teacher frontend was changed; school administrative operations remain in the separate admin app. Application-owned terms use learners and school classes. Original educational content and locally painted branding remain bundled offline.
