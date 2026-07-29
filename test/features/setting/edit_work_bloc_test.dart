import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/bloc/edit_work_bloc.dart';
import 'package:talent_flow/features/setting/bloc/edit_work_event.dart';
import 'package:talent_flow/features/setting/bloc/edit_work_state.dart';
import 'package:talent_flow/features/setting/model/edit_work_request_model.dart';
import 'package:talent_flow/features/setting/repo/edit_work_repository.dart';

void main() {
  test('EditWorkBloc forwards a typed update request', () async {
    final repository = _FakeEditWorkRepository();
    final bloc = EditWorkBloc(repository: repository);
    final request = EditWorkRequestModel(
      id: 4,
      title: 'Work',
      description: 'Description',
      date: '2026-07-29',
      skillIds: const [2],
      newFiles: const [],
      oldFiles: const [],
    );

    bloc.add(WorkUpdateSubmitted(request));

    final state = await bloc.stream.firstWhere(
      (state) => state is EditWorkSucceeded,
    ) as EditWorkSucceeded;
    expect(repository.updateRequest, same(request));
    expect(state.action, EditWorkAction.updated);
    await bloc.close();
  });

  test('EditWorkBloc forwards the work id for deletion', () async {
    final repository = _FakeEditWorkRepository();
    final bloc = EditWorkBloc(repository: repository)
      ..add(const WorkDeleteSubmitted(11));

    final state = await bloc.stream.firstWhere(
      (state) => state is EditWorkSucceeded,
    ) as EditWorkSucceeded;
    expect(repository.deletedId, 11);
    expect(state.action, EditWorkAction.deleted);
    await bloc.close();
  });
}

class _FakeEditWorkRepository implements EditWorkRepository {
  EditWorkRequestModel? updateRequest;
  int? deletedId;

  @override
  Future<Either<ServerFailure, String>> updateWork({
    required EditWorkRequestModel request,
  }) async {
    updateRequest = request;
    return right('Updated');
  }

  @override
  Future<Either<ServerFailure, String>> deleteWork(int id) async {
    deletedId = id;
    return right('Deleted');
  }
}
