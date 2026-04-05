sealed class MyProjectsEvent {
  const MyProjectsEvent();
}

class ProjectsRequested extends MyProjectsEvent {
  const ProjectsRequested({this.status, this.categoryId});

  final String? status;
  final int? categoryId;
}

class ProjectDetailsRequested extends MyProjectsEvent {
  const ProjectDetailsRequested(this.projectId);

  final int projectId;
}
