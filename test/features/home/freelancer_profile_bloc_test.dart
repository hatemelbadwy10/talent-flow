import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/bloc/freelancer_profile_bloc.dart';
import 'package:talent_flow/features/home/bloc/freelancer_profile_event.dart';
import 'package:talent_flow/features/home/bloc/freelancer_profile_state.dart';
import 'package:talent_flow/features/home/model/freelancer_profile_model.dart';
import 'package:talent_flow/features/home/repo/freelancer_profile_repository.dart';

void main() {
  test('FreelancerProfileBloc emits the typed profile', () async {
    final profile = FreelancerProfileModel.fromJson(const {'id': 1});
    final bloc = FreelancerProfileBloc(
      repository: _FakeProfileRepository(right(profile)),
    );

    bloc.add(const FreelancerProfileRequested(1));
    final state = await bloc.stream.firstWhere(
      (state) => state is FreelancerProfileLoaded,
    ) as FreelancerProfileLoaded;

    expect(state.profile, same(profile));
    await bloc.close();
  });

  test('FreelancerProfileBloc exposes repository failures', () async {
    final bloc = FreelancerProfileBloc(
      repository: _FakeProfileRepository(
        left(ServerFailure('Unable to load profile')),
      ),
    );

    bloc.add(const FreelancerProfileRequested(1));
    final state = await bloc.stream.firstWhere(
      (state) => state is FreelancerProfileFailed,
    ) as FreelancerProfileFailed;

    expect(state.message, 'Unable to load profile');
    await bloc.close();
  });
}

class _FakeProfileRepository implements FreelancerProfileRepository {
  _FakeProfileRepository(this.result);

  final Either<ServerFailure, FreelancerProfileModel> result;

  @override
  Future<Either<ServerFailure, FreelancerProfileModel>> getProfile(
      int id) async {
    return result;
  }
}
