import '../../projects/model/my_projects_model.dart';

sealed class NewProjectsState {
  const NewProjectsState();
}

final class NewProjectsInitial extends NewProjectsState {
  const NewProjectsInitial();
}

final class ProjectFeedLoading extends NewProjectsState {
  const ProjectFeedLoading();
}

final class ProjectFeedLoaded extends NewProjectsState {
  const ProjectFeedLoaded(this.projects);
  final List<MyProjectsModel> projects;
}

final class ProjectFeedFailed extends NewProjectsState {
  const ProjectFeedFailed(this.message);
  final String message;
}

final class OfferSubmitting extends NewProjectsState {
  const OfferSubmitting();
}

final class OfferSubmissionSucceeded extends NewProjectsState {
  const OfferSubmissionSucceeded(this.message);
  final String message;
}

final class OfferSubmissionFailed extends NewProjectsState {
  const OfferSubmissionFailed(this.message);
  final String message;
}

final class ProjectFavoriteSucceeded extends NewProjectsState {
  const ProjectFavoriteSucceeded({
    required this.projectId,
    required this.message,
  });
  final int projectId;
  final String message;
}

final class ProjectFavoriteFailed extends NewProjectsState {
  const ProjectFavoriteFailed({
    required this.projectId,
    required this.message,
  });
  final int projectId;
  final String message;
}
