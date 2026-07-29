sealed class NewProjectsEvent {
  const NewProjectsEvent();
}

final class ProjectFeedRequested extends NewProjectsEvent {
  const ProjectFeedRequested({
    this.specializationId,
    this.sortBy,
    this.search,
  });

  final int? specializationId;
  final String? sortBy;
  final String? search;
}

final class OfferSubmitted extends NewProjectsEvent {
  const OfferSubmitted({
    required this.projectId,
    required this.description,
    required this.answers,
    this.proposalId,
  });

  final int projectId;
  final String description;
  final List<Map<String, dynamic>> answers;
  final int? proposalId;
}

final class ProjectFavoriteToggled extends NewProjectsEvent {
  const ProjectFavoriteToggled(this.projectId);
  final int projectId;
}
