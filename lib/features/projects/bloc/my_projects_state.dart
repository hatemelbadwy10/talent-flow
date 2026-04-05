import 'package:equatable/equatable.dart';

import '../model/my_projects_model.dart';
import '../model/single_project_model.dart';

sealed class MyProjectsState extends Equatable {
  const MyProjectsState();

  @override
  List<Object?> get props => [];
}

class MyProjectsInitial extends MyProjectsState {
  const MyProjectsInitial();
}

class MyProjectsLoading extends MyProjectsState {
  const MyProjectsLoading();
}

class MyProjectsFailure extends MyProjectsState {
  const MyProjectsFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class MyProjectsLoaded extends MyProjectsState {
  const MyProjectsLoaded(this.projects);

  final List<MyProjectsModel> projects;

  @override
  List<Object?> get props => [projects];
}

class ProjectDetailsLoaded extends MyProjectsState {
  const ProjectDetailsLoaded(this.project);

  final SingleProjectModel project;

  @override
  List<Object?> get props => [project];
}
