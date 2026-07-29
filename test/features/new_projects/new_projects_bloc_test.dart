import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/new_projects/bloc/new_projects_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/new_projects_event.dart';
import 'package:talent_flow/features/new_projects/bloc/new_projects_state.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repository.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';

void main() {
  test('project feed forwards its filters and emits typed projects', () async {
    final repository = _FakeNewProjectsRepository();
    final bloc = NewProjectsBloc(repository: repository);

    bloc.add(const ProjectFeedRequested(
      specializationId: 9,
      sortBy: 'latest',
      search: 'flutter',
    ));

    final state = await bloc.stream.firstWhere(
      (state) => state is ProjectFeedLoaded,
    ) as ProjectFeedLoaded;
    expect(repository.specializationId, 9);
    expect(repository.sortBy, 'latest');
    expect(repository.search, 'flutter');
    expect(state.projects, same(repository.projects));
    await bloc.close();
  });

  test('offer submission forwards proposal data and emits success', () async {
    final repository = _FakeNewProjectsRepository();
    final bloc = NewProjectsBloc(repository: repository);
    const answers = [
      {'question_id': 3, 'answer': 'Yes'},
    ];

    bloc.add(const OfferSubmitted(
      projectId: 12,
      description: 'My offer',
      proposalId: 5,
      answers: answers,
    ));

    final state = await bloc.stream.firstWhere(
      (state) => state is OfferSubmissionSucceeded,
    ) as OfferSubmissionSucceeded;
    expect(repository.projectId, 12);
    expect(repository.description, 'My offer');
    expect(repository.proposalId, 5);
    expect(repository.answers, answers);
    expect(state.message, 'Offer saved');
    await bloc.close();
  });

  test('favorite failure preserves the affected project id', () async {
    final repository = _FakeNewProjectsRepository(failFavorite: true);
    final bloc = NewProjectsBloc(repository: repository);

    bloc.add(const ProjectFavoriteToggled(21));

    final state = await bloc.stream.firstWhere(
      (state) => state is ProjectFavoriteFailed,
    ) as ProjectFavoriteFailed;
    expect(state.projectId, 21);
    expect(state.message, 'Favorite failed');
    await bloc.close();
  });
}

class _FakeNewProjectsRepository implements NewProjectsRepository {
  _FakeNewProjectsRepository({this.failFavorite = false});

  final bool failFavorite;
  final projects = <MyProjectsModel>[MyProjectsModel(id: 1)];
  int? specializationId;
  String? sortBy;
  String? search;
  int? projectId;
  String? description;
  List<Map<String, dynamic>>? answers;
  int? proposalId;

  @override
  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjectFeed({
    int? specializationId,
    String? sortBy,
    String? search,
  }) async {
    this.specializationId = specializationId;
    this.sortBy = sortBy;
    this.search = search;
    return right(projects);
  }

  @override
  Future<Either<ServerFailure, String>> submitOffer({
    required int projectId,
    required String description,
    required List<Map<String, dynamic>> answers,
    int? proposalId,
  }) async {
    this.projectId = projectId;
    this.description = description;
    this.answers = answers;
    this.proposalId = proposalId;
    return right('Offer saved');
  }

  @override
  Future<Either<ServerFailure, String>> toggleProjectFavorite(
    int projectId,
  ) async {
    this.projectId = projectId;
    return failFavorite
        ? left(ServerFailure('Favorite failed'))
        : right('Favorite updated');
  }
}
