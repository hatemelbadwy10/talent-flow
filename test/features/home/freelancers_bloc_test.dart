import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/home/bloc/freelancers_bloc.dart';
import 'package:talent_flow/features/home/bloc/freelancers_event.dart';
import 'package:talent_flow/features/home/bloc/freelancers_state.dart';
import 'package:talent_flow/features/home/model/freelancers_model.dart';
import 'package:talent_flow/features/home/repo/freelancers_repository.dart';

void main() {
  group('FreelancersBloc', () {
    test('passes category and search filters to the repository', () async {
      final repository = _FakeFreelancersRepository(right(const []));
      final bloc = FreelancersBloc(repository: repository);

      bloc.add(const FreelancersRequested(
        categoryId: 7,
        search: 'flutter',
      ));
      await bloc.stream.firstWhere((state) => state is FreelancersLoaded);

      expect(repository.categoryId, 7);
      expect(repository.search, 'flutter');
      await bloc.close();
    });

    test('emits the typed freelancer list', () async {
      final freelancer = FreelancersModel.fromJson(const {
        'id': 1,
        'name': 'Talent',
        'rating': '4.5',
      });
      final bloc = FreelancersBloc(
        repository: _FakeFreelancersRepository(right([freelancer])),
      );

      bloc.add(const FreelancersRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state is FreelancersLoaded,
      ) as FreelancersLoaded;

      expect(state.freelancers.single, same(freelancer));
      await bloc.close();
    });

    test('exposes repository failures', () async {
      final bloc = FreelancersBloc(
        repository: _FakeFreelancersRepository(
          left(ServerFailure('Unable to load freelancers')),
        ),
      );

      bloc.add(const FreelancersRequested());
      final state = await bloc.stream.firstWhere(
        (state) => state is FreelancersFailed,
      ) as FreelancersFailed;

      expect(state.message, 'Unable to load freelancers');
      await bloc.close();
    });
  });
}

class _FakeFreelancersRepository implements FreelancersRepository {
  _FakeFreelancersRepository(this.result);

  final Either<ServerFailure, List<FreelancersModel>> result;
  int? categoryId;
  String? search;

  @override
  Future<Either<ServerFailure, List<FreelancersModel>>> getFreelancerList({
    int? categoryId,
    String? search,
  }) async {
    this.categoryId = categoryId;
    this.search = search;
    return result;
  }
}
