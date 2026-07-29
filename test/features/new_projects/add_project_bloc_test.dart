import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_event.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_event.dart';
import 'package:talent_flow/features/new_projects/bloc/selection_option_state.dart';
import 'package:talent_flow/features/new_projects/model/project_question.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';
import 'package:talent_flow/features/new_projects/repo/add_project_repository.dart';
import 'package:talent_flow/features/new_projects/repo/selection_options_repository.dart';

void main() {
  test('AddProjectBloc keeps typed form values and submits them', () async {
    final repository = _FakeAddProjectRepository();
    final bloc = AddProjectBloc(repository: repository)
      ..add(const UpdateSpecializationId(
        specializationId: 4,
        specializationName: 'Mobile',
      ))
      ..add(const UpdateTitle(title: 'App'))
      ..add(const UpdateDescription(description: 'Build an app'))
      ..add(const UpdateSkills(skills: [2, 3], skillNames: ['Dart', 'Flutter']))
      ..add(const UpdateBudget(budget: '100-500'))
      ..add(const UpdateDuration(duration: 10));

    await bloc.stream.firstWhere((state) => state.duration == 10);
    bloc.add(SubmitProject());

    final state = await bloc.stream.firstWhere((state) => state.isSubmitted);
    expect(repository.specializationId, 4);
    expect(repository.skills, [2, 3]);
    expect(repository.budget, '100-500');
    expect(state.successMessage, 'Project created');
    await bloc.close();
  });

  test('SelectionOptionBloc emits typed options', () async {
    final repository = _FakeSelectionOptionsRepository();
    final bloc = SelectionOptionBloc(repository: repository)
      ..add(const SelectionOptionsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is SelectionOptionLoaded,
    ) as SelectionOptionLoaded;
    expect(state.options, same(repository.options));
    await bloc.close();
  });

  test('SelectionOptionBloc exposes repository failures', () async {
    final bloc = SelectionOptionBloc(
      repository: _FakeSelectionOptionsRepository(fail: true),
    )..add(const SelectionOptionsRequested());

    final state = await bloc.stream.firstWhere(
      (state) => state is SelectionOptionFailed,
    ) as SelectionOptionFailed;
    expect(state.message, 'Options failed');
    await bloc.close();
  });
}

class _FakeAddProjectRepository implements AddProjectRepository {
  int? specializationId;
  List<int>? skills;
  String? budget;

  @override
  Future<Either<ServerFailure, String>> addProject({
    required int specializationId,
    required String title,
    required String description,
    required List<int> skills,
    required String budget,
    required int duration,
    List<File>? files,
    String? filesDescription,
    List<String>? similarProjects,
    String? requiredToBeReceived,
    List<ProjectQuestion>? questions,
  }) async {
    this.specializationId = specializationId;
    this.skills = skills;
    this.budget = budget;
    return right('Project created');
  }
}

class _FakeSelectionOptionsRepository implements SelectionOptionsRepository {
  _FakeSelectionOptionsRepository({this.fail = false});

  final bool fail;
  final options = SelectionModel(
    specializations: const {'4': 'Mobile'},
    jobTitles: const {'1': 'Developer'},
    skills: const {'2': 'Dart'},
  );

  @override
  Future<Either<ServerFailure, SelectionModel>> getSelectionOptions() async {
    return fail ? left(ServerFailure('Options failed')) : right(options);
  }
}
