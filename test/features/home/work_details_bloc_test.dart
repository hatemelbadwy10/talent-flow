import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/bloc/work_details_bloc.dart';
import 'package:talent_flow/features/home/model/work_details_model.dart';
import 'package:talent_flow/features/home/repo/work_details_repository.dart';

void main() {
  group('WorkDetailsBloc', () {
    test('passes the work id and emits typed details', () async {
      final work = WorkDetailsModel.fromJson(const {
        'id': 5,
        'title': 'Mobile app',
      });
      final repository = _FakeWorkRepository(right(work));
      final bloc = WorkDetailsBloc(repository: repository);

      bloc.add(const WorkDetailsRequested(5));
      final state = await bloc.stream.firstWhere(
        (state) => state is WorkDetailsLoaded,
      ) as WorkDetailsLoaded;

      expect(repository.requestedId, 5);
      expect(state.work, same(work));
      await bloc.close();
    });

    test('exposes repository failures', () async {
      final bloc = WorkDetailsBloc(
        repository: _FakeWorkRepository(
          left(ServerFailure('Unable to load work')),
        ),
      );

      bloc.add(const WorkDetailsRequested(5));
      final state = await bloc.stream.firstWhere(
        (state) => state is WorkDetailsFailed,
      ) as WorkDetailsFailed;

      expect(state.message, 'Unable to load work');
      await bloc.close();
    });
  });
}

class _FakeWorkRepository implements WorkDetailsRepository {
  _FakeWorkRepository(this.result);

  final Either<ServerFailure, WorkDetailsModel> result;
  int? requestedId;

  @override
  Future<Either<ServerFailure, WorkDetailsModel>> getWork(int id) async {
    requestedId = id;
    return result;
  }
}
