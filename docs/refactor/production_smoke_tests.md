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
- Confirm loading, empty, success, offline, and API failure states.

## Account roles

- As a freelancer, browse projects, submit and update an offer, manage works,
  open chats, and complete identity verification.
- As an entrepreneur, browse freelancers, create a project, manage proposals,
  create a contract, add a bank account, and complete a payment.
- Confirm role-specific actions remain hidden for the other account type.

## Contracts, payments, and realtime

- Open contract lists and details, exercise the available status actions, and
  download a contract PDF.
- Request and confirm a contract payment, including validation and API failure.
- Open chat from the list, a project proposal, and a notification.
- Send text and voice messages and verify unread counters update.
- Restart or resume the app and confirm the realtime user subscription is
  restored without duplicate messages.

## Baseline

At refactor start (`0b4cb7a`), `flutter analyze` reports 163 issues. Refactor PRs
must introduce no new issues and must leave every touched Dart file warning-free.

The current controlled baseline is 127 info-only issues with zero warnings and
zero errors. CI enforces this through `tool/check_analyzer_baseline.sh`.

## Latest local smoke evidence

On 2026-07-30, commit `f6d1636` and later changes were built and launched on an
iPhone 16 Pro iOS 26.0 simulator:

- Firebase and Easy Localization initialized without a startup exception.
- The login screen rendered in English.
- The in-app language control switched the same screen to Arabic with RTL
  layout and persisted locale `ar`.
- Relaunching the installed app restored the Arabic locale.
- Password-recovery navigation opened the email/WhatsApp verification screen.
- Registration navigation opened role selection and then the Arabic freelancer
  registration form.
- The final automated suite passed 110 tests, including loading, empty,
  success, failure, offline authentication, session restoration, route
  compatibility, model parsing, and realtime boundaries.

Authenticated freelancer and entrepreneur scenarios still require dedicated
test-account credentials and a reachable production-compatible backend. Record
those results in `acceptance_evidence.md` before a production merge.
