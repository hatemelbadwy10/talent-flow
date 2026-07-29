import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/dashboard_bloc.dart';
import 'package:talent_flow/features/setting/bloc/dashboard_event.dart';
import 'package:talent_flow/features/setting/bloc/dashboard_state.dart';
import 'package:talent_flow/features/setting/model/dashboard_request_model.dart';
import 'package:talent_flow/features/setting/model/dashboard_response_model.dart';
import 'package:talent_flow/features/setting/repo/dashboard_repository.dart';

void main() {
  test('DashboardBloc emits the typed dashboard', () async {
    final repository = _FakeDashboardRepository();
    final bloc = DashboardBloc(repository: repository)
      ..add(const DashboardRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is DashboardLoaded,
    ) as DashboardLoaded;
    expect(state.dashboard, same(repository.dashboard));
    await bloc.close();
  });

  test('DashboardBloc exposes repository failures', () async {
    final bloc = DashboardBloc(
      repository: _FakeDashboardRepository(fail: true),
    )..add(const DashboardRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is DashboardFailed,
    ) as DashboardFailed;
    expect(state.message, 'Dashboard failed');
    await bloc.close();
  });
}

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository({this.fail = false});

  final bool fail;
  final dashboard = const DashboardResponseModel(
    statuses: [],
    recentProjects: [],
    rawPayload: {},
  );

  @override
  Future<Either<ServerFailure, DashboardResponseModel>> getProfileDashboard({
    DashboardRequestModel request = const DashboardRequestModel(),
  }) async {
    return fail ? left(ServerFailure('Dashboard failed')) : right(dashboard);
  }
}
