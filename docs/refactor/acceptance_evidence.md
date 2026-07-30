# Refactor acceptance evidence

This matrix records the evidence required before merging the production-safe
refactor. Automated evidence is repeatable in CI. Account-backed smoke evidence
must be recorded manually because it uses real authentication and backend state.

## Automated evidence

| Requirement | Evidence |
| --- | --- |
| Valid login and persistence | `test/features/auth/login_bloc_test.dart` |
| Invalid credentials | `test/features/auth/login_bloc_test.dart` |
| Unverified account and resend | `login_bloc_test.dart`, `send_verification_bloc_test.dart` |
| Registration and verification | `register_bloc_test.dart`, `confirm_code_bloc_test.dart` |
| Password recovery/change | `confirm_code_bloc_test.dart`, `change_password_bloc_test.dart` |
| Social login success/failure | `social_media_bloc_test.dart` |
| Offline login | `login_bloc_test.dart` |
| Persistence after restart/network failure | `test/main_blocs/user_bloc_test.dart` |
| Loading, empty, failure, success widgets | `service_category_view_test.dart` |
| Typed routes and legacy route compatibility | `route_args_compatibility_test.dart` |
| Project, offer, payment, profile, settings, and chat transitions | Feature Bloc tests under `test/features/` |
| Realtime subscription boundary | `freelancer_chat_bloc_test.dart` |
| Dependency registration | `test/data/config/di_test.dart` |
| Wire-format parsing and serialization | Model tests under `test/features/models/` |
| No analyzer regression | `tool/check_analyzer_baseline.sh` |

Current gate result:

- `flutter test`: 110 passed.
- analyzer: 127 info-only issues, zero warnings, zero errors.
- iOS simulator: application startup, English/Arabic rendering, locale restore
  after relaunch, password-recovery navigation, role selection, and freelancer
  registration navigation passed.

## Account-backed smoke evidence

Record the tester, date, backend environment, app commit, and result for every
row. Do not mark a row passed without executing it.

| Flow | Freelancer | Entrepreneur |
| --- | --- | --- |
| Login and home | Pending credentials | Pending credentials |
| Logout and restart persistence | Pending credentials | Pending credentials |
| Discovery and role-specific navigation | Pending credentials | Pending credentials |
| Projects, offers, and proposals | Pending credentials | Pending credentials |
| Contracts and payments | Pending credentials | Pending credentials |
| Profile, settings, and identity verification | Pending credentials | Pending credentials |
| Chat, voice messages, unread counts, resume | Pending credentials | Pending credentials |
| Offline and API failure presentation | Pending credentials | Pending credentials |
| Firebase notification/deep-link entry | Pending credentials | Pending credentials |

## Release decision

Automated and unauthenticated runtime gates are green. Production merge remains
conditional on completing the account-backed table with safe test accounts.
