# Contributing during the refactor

## Before coding

1. Branch from the current production-safe refactor branch.
2. Keep the PR limited to one independently releasable feature slice.
3. Record the current analyzer count if the baseline changes intentionally.

## Implementation checklist

- Preserve the current UI, routes, localization keys, backend payloads, and
  persistence keys.
- Add immutable, feature-specific events and states.
- Inject repository interfaces; do not call GetIt from feature code.
- Keep Dio responses inside concrete repositories.
- Perform navigation, snackbars, and dialogs in presentation listeners.
- Fix every analyzer issue in touched files.

## Verification

Run:

```sh
flutter test
./tool/check_analyzer_baseline.sh
```

Then manually execute the relevant entries in
`docs/refactor/production_smoke_tests.md` in Arabic and English.

## Commit and release

- Use a focused commit describing the migrated slice.
- Release and monitor each feature independently.
- Watch authentication failures, crashes, API failures, and navigation
  regressions before beginning another high-risk slice.
