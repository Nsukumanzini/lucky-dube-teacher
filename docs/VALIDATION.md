# Teacher web app validation — 22 November 2026

Environment: Flutter 3.50.1 stable, Dart 3.14.0, Linux.

- `flutter pub get`: passed.
- `dart format lib test`: passed.
- `flutter analyze`: no issues found.
- `flutter test`: 17 passed.
- Repository checks cover teacher credentials, assigned-class boundaries, teacher-scoped content, mark bounds/draft-vs-published averages, complete attendance, local messaging, profile-scoped reset and language persistence.
- Widget checks cover all primary screens plus attendance saving, result publishing, lesson publishing and messaging at 360, 390, 768, 1024 and 1440 pixels. isiZulu navigation and unassigned-class rejection were checked at 360, 768 and 1440 pixels.
- A teacher-only sign-in test verifies there is no administration role selector.
- `flutter build web --release --no-web-resources-cdn`: passed; output is build/web.

Only web is targeted. No native platform build or real school-service integration is claimed. See FEATURES.md and README.md for the local frontend boundaries.

Unused learner translation entries were removed from the independent teacher catalogue; all 17 tests still passed and the release build succeeded after that size reduction.
