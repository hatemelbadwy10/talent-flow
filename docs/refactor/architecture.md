# Talent Flow architecture

Talent Flow keeps its feature-first Flutter structure and uses Flutter Bloc,
GetIt, Dio, Firebase, and the existing navigation system.

## Runtime composition

`data/config/di.dart` registers concrete implementations. `main.dart`
configures application-wide services and provides the global `UserBloc`.
`navigation/custom_navigation.dart` constructs screens and injects their
feature dependencies.

No feature screen, widget, Bloc, repository, helper, or realtime service should
resolve dependencies from GetIt directly.

## Feature flow

1. A widget sends a feature-specific event.
2. The Bloc calls an injected repository interface.
3. The concrete repository uses Dio internally and parses the existing backend
   wire format.
4. The repository returns a typed model or `ServerFailure`.
5. The Bloc emits a feature-specific state.
6. A widget renders the state; a `BlocListener` performs navigation, dialog, or
   snackbar side effects.

## Compatibility constraints

The refactor must preserve:

- route names, arguments, deep links, and back-navigation behavior;
- endpoint paths, request fields, response parsing, and authentication headers;
- SharedPreferences keys and session restoration;
- localization keys and Arabic/English behavior;
- Firebase, Remote Config, realtime subscriptions, and platform configuration;
- the current visual design and user-visible loading/error behavior.

## Migration status

Authentication, home/discovery, projects/offers, contracts/payments,
profiles/settings, chat/realtime, splash, and onboarding now use typed Bloc and
repository boundaries. Generic event/state infrastructure has been removed.
GetIt access is restricted to the composition roots listed above.
