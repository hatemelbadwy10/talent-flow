# Refactor conventions

## Feature boundaries

- Keep features independently releasable and preserve visible behavior, routes,
  localization keys, storage keys, and backend payloads.
- Organize migrated features around `presentation`, `data`, and
  feature-specific models. Move files only when the active slice requires it.
- Use feature-specific immutable Bloc events and states. Do not reintroduce
  generic `Get`, `Click`, `Done`, `AppEvent`, or `AppState` types.
- Keep business rules outside widget `build` methods. Split large screens into
  focused private widgets without redesigning them.

## Dependency direction

- GetIt is used only by the composition roots in `main.dart`,
  `data/config/di.dart`, and `navigation/custom_navigation.dart`.
- Screens, widgets, Blocs, repositories, realtime services, and helpers receive
  dependencies through constructors or explicit one-time configuration.
- Depend on repository interfaces at feature boundaries. Concrete repositories
  are selected only by the composition root.
- Repositories parse transport responses and return typed models or
  `ServerFailure`; Dio `Response` objects do not escape the data layer.

## Presentation side effects

- Blocs contain state transitions and business flow only.
- Widgets and `BlocListener`s own navigation, snackbars, and dialogs.
- A Bloc emits an explicit outcome before presentation performs a side effect.

## Quality gate

- Add repository and Bloc unit tests for parsing, transitions, validation, and
  business rules.
- Add widget tests for critical loading, success, empty, and failure states.
- Run `flutter test` and `./tool/check_analyzer_baseline.sh` before every PR.
- Touched Dart files must report no analyzer issues.
- Do not combine unrelated lint cleanup with a feature migration.
