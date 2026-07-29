# Production smoke tests

Run these checks in Arabic and English with both freelancer and entrepreneur
accounts before releasing a refactored feature.

## Authentication

- Log in with valid credentials and confirm the correct home experience opens.
- Log in with invalid credentials and confirm the API message is displayed.
- Log in with an unverified account, confirm a code is requested, and verify the
  verification screen receives the email address.
- Complete registration, verification, password recovery, and social login.
- Restart the app after login and confirm the authenticated session is restored.
- Repeat the failure flows while offline.

## Shared application behavior

- Confirm forward navigation, back navigation, and deep links still resolve.
- Confirm loading controls cannot submit the same request twice.
- Confirm Firebase messaging, Remote Config, and notification navigation work.
- Confirm project, contract, payment, profile, and chat entry points still open.

## Baseline

At refactor start (`0b4cb7a`), `flutter analyze` reports 163 issues. Refactor PRs
must introduce no new issues and must leave every touched Dart file warning-free.
