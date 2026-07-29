import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/projects/bloc/my_projects_bloc.dart';
import 'package:talent_flow/features/projects/bloc/my_projects_event.dart';
import 'package:talent_flow/features/projects/bloc/my_projects_state.dart';
import 'package:talent_flow/features/projects/bloc/project_details_bloc.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';
import 'package:talent_flow/features/projects/model/single_project_model.dart';
import 'package:talent_flow/features/projects/repo/projects_repository.dart';

void main() {
  test('MyProjectsBloc forwards status and category filters', () async {
    final repository = _FakeProjectsRepository();
    final bloc = MyProjectsBloc(repository: repository);
    bloc.add(const MyProjectsRequested(status: 'Open', categoryId: 4));
    await bloc.stream.firstWhere((state) => state is MyProjectsLoaded);
    expect(repository.status, 'Open');
    expect(repository.categoryId, 4);
    await bloc.close();
  });

  test('ProjectDetailsBloc emits a typed project', () async {
    final repository = _FakeProjectsRepository();
    final bloc = ProjectDetailsBloc(repository: repository);
    bloc.add(const ProjectDetailsRequested(8));
    final state = await bloc.stream.firstWhere(
      (state) => state is ProjectDetailsLoaded,
    ) as ProjectDetailsLoaded;
    expect(repository.projectId, 8);
    expect(state.project, same(repository.project));
    await bloc.close();
  });

  test('project blocs expose repository failures', () async {
    final repository = _FakeProjectsRepository(fail: true);
    final bloc = MyProjectsBloc(repository: repository);
    bloc.add(const MyProjectsRequested());
    final state = await bloc.stream.firstWhere(
      (state) => state is MyProjectsFailed,
    ) as MyProjectsFailed;
    expect(state.message, 'Projects failed');
    await bloc.close();
  });
}

class _FakeProjectsRepository implements ProjectsRepository {
  _FakeProjectsRepository({this.fail = false});

  final bool fail;
  String? status;
  int? categoryId;
  int? projectId;
  final project = SingleProjectModel.fromJson(const {'id': 8});

  @override
  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjectList({
    String? status,
    int? categoryId,
  }) async {
    this.status = status;
    this.categoryId = categoryId;
    return fail ? left(ServerFailure('Projects failed')) : right(const []);
  }

  @override
  Future<Either<ServerFailure, SingleProjectModel>> getProjectDetails(
    int id,
  ) async {
    projectId = id;
    return fail ? left(ServerFailure('Project failed')) : right(project);
  }
}
