sealed class NewProjectsEvent {
  const NewProjectsEvent();
}

class NewProjectsRequested extends NewProjectsEvent {
  const NewProjectsRequested();
}

class ProjectOfferSubmitted extends NewProjectsEvent {
  const ProjectOfferSubmitted({
    required this.projectId,
    required this.description,
  });

  final int projectId;
  final String description;
}

class ProjectFavouriteToggled extends NewProjectsEvent {
  const ProjectFavouriteToggled(this.projectId);

  final int projectId;
}
