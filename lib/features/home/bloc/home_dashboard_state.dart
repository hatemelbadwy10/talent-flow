import '../model/home_model.dart';

sealed class HomeDashboardState {
  const HomeDashboardState();
}

final class HomeDashboardInitial extends HomeDashboardState {
  const HomeDashboardInitial();
}

final class HomeDashboardLoading extends HomeDashboardState {
  const HomeDashboardLoading();
}

final class HomeDashboardLoaded extends HomeDashboardState {
  const HomeDashboardLoaded(this.dashboard);

  final HomeModel dashboard;
}

final class HomeDashboardFailed extends HomeDashboardState {
  const HomeDashboardFailed(this.message);

  final String message;
}
