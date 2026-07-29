# Refactor conventions

- Keep features independently releasable and preserve visible behavior.
- Use feature-specific immutable Bloc events and states.
- Inject repository interfaces through constructors.
- Repositories parse transport responses; Dio `Response` objects do not escape
  the data layer.
- Blocs contain business flow only. Widgets and `BlocListener`s own navigation,
  snackbars, and dialogs.
- Access GetIt only at composition points such as page providers and application
  startup.
- Add repository/Bloc unit tests and critical widget tests with every migrated
  flow.
