import '../model/my_projects_model.dart';

sealed class MyProjectsState {
  const MyProjectsState();
}

final class MyProjectsInitial extends MyProjectsState {
  const MyProjectsInitial();
}

final class MyProjectsLoading extends MyProjectsState {
  const MyProjectsLoading();
}

final class MyProjectsLoaded extends MyProjectsState {
  const MyProjectsLoaded(this.projects);

  final List<MyProjectsModel> projects;
}

final class MyProjectsFailed extends MyProjectsState {
  const MyProjectsFailed(this.message);

  final String message;
}
