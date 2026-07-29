import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/bloc/entrepreneur_profile_bloc.dart';
import 'package:talent_flow/features/home/model/entrepreneur_profile_model.dart';
import 'package:talent_flow/features/home/repo/entrepreneur_profile_repository.dart';

void main() {
  test('EntrepreneurProfileBloc emits the typed profile', () async {
    final profile = EntrepreneurProfileModel.fromJson(const {'id': 1});
    final bloc = EntrepreneurProfileBloc(
      repository: _FakeRepository(right(profile)),
    );
    bloc.add(const EntrepreneurProfileRequested(1));
    final state = await bloc.stream.firstWhere(
      (state) => state is EntrepreneurProfileLoaded,
    ) as EntrepreneurProfileLoaded;
    expect(state.profile, same(profile));
    await bloc.close();
  });

  test('EntrepreneurProfileBloc exposes failures', () async {
    final bloc = EntrepreneurProfileBloc(
      repository: _FakeRepository(left(ServerFailure('Load failed'))),
    );
    bloc.add(const EntrepreneurProfileRequested(1));
    final state = await bloc.stream.firstWhere(
      (state) => state is EntrepreneurProfileFailed,
    ) as EntrepreneurProfileFailed;
    expect(state.message, 'Load failed');
    await bloc.close();
  });
}

class _FakeRepository implements EntrepreneurProfileRepository {
  _FakeRepository(this.result);
  final Either<ServerFailure, EntrepreneurProfileModel> result;

  @override
  Future<Either<ServerFailure, EntrepreneurProfileModel>> getEntrepreneur(
    int id,
  ) async =>
      result;
}
