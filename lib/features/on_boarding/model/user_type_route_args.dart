final class UserTypeRouteArgs {
  const UserTypeRouteArgs({this.fromLogin = false});

  final bool fromLogin;

  factory UserTypeRouteArgs.fromRoute(Object? value) {
    if (value is UserTypeRouteArgs) return value;
    final map = value is Map ? value : const <Object?, Object?>{};
    return UserTypeRouteArgs(fromLogin: map['from_login'] == true);
  }
}
