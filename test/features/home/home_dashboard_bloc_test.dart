import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/bloc/home_dashboard_bloc.dart';
import 'package:talent_flow/features/home/bloc/home_dashboard_event.dart';
import 'package:talent_flow/features/home/bloc/home_dashboard_state.dart';
import 'package:talent_flow/features/home/model/home_model.dart';
import 'package:talent_flow/features/home/repo/home_dashboard_repository.dart';

void main() {
  group('HomeDashboardBloc', () {
    test('emits loading then the parsed dashboard', () async {
      final dashboard = HomeModel.fromJson(const {
        'categories': [],
        'cards': [],
        'partners': [],
      });
      final bloc = HomeDashboardBloc(
        repository: _FakeHomeDashboardRepository(right(dashboard)),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<HomeDashboardLoading>(),
          isA<HomeDashboardLoaded>()
              .having((state) => state.dashboard, 'dashboard', same(dashboard)),
        ]),
      );
      bloc.add(const HomeDashboardRequested());
      await bloc.stream.firstWhere((state) => state is HomeDashboardLoaded);
      await bloc.close();
    });

    test('exposes the repository failure message', () async {
      final bloc = HomeDashboardBloc(
        repository: _FakeHomeDashboardRepository(
          left(ServerFailure('Unable to load home')),
        ),
      );

      bloc.add(const HomeDashboardRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state is HomeDashboardFailed,
      ) as HomeDashboardFailed;

      expect(state.message, 'Unable to load home');
      await bloc.close();
    });
  });
}

class _FakeHomeDashboardRepository implements HomeDashboardRepository {
  _FakeHomeDashboardRepository(this.result);

  final Either<ServerFailure, HomeModel> result;

  @override
  Future<Either<ServerFailure, HomeModel>> getDashboard() async => result;
}
