import '../model/dashboard_response_model.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.dashboard);
  final DashboardResponseModel dashboard;
}

final class DashboardFailed extends DashboardState {
  const DashboardFailed(this.message);
  final String message;
}
