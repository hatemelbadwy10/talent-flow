import '../bloc/portofilo_form_bloc.dart';

final class UserCompletionRouteArgs {
  const UserCompletionRouteArgs({this.fromOnboarding = false});

  final bool fromOnboarding;

  factory UserCompletionRouteArgs.fromRoute(Object? value) {
    if (value is UserCompletionRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return UserCompletionRouteArgs(
      fromOnboarding: map['fromOnboarding'] == true,
    );
  }
}

final class AcceptanceTestRouteArgs {
  const AcceptanceTestRouteArgs({this.pendingWorks = const []});

  final List<SinglePortfolioData> pendingWorks;

  factory AcceptanceTestRouteArgs.fromRoute(Object? value) {
    if (value is AcceptanceTestRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    final rawWorks = map['pendingWorks'];
    return AcceptanceTestRouteArgs(
      pendingWorks: rawWorks is List
          ? rawWorks.whereType<SinglePortfolioData>().toList(growable: false)
          : const [],
    );
  }
}
