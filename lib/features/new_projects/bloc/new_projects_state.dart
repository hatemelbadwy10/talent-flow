import 'package:equatable/equatable.dart';

import '../../projects/model/my_projects_model.dart';

sealed class NewProjectsState extends Equatable {
  const NewProjectsState();

  @override
  List<Object?> get props => [];
}

class NewProjectsInitial extends NewProjectsState {
  const NewProjectsInitial();
}

class NewProjectsLoading extends NewProjectsState {
  const NewProjectsLoading();
}

class NewProjectsFailure extends NewProjectsState {
  const NewProjectsFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class NewProjectsLoaded extends NewProjectsState {
  const NewProjectsLoaded(this.projects);

  final List<MyProjectsModel> projects;

  @override
  List<Object?> get props => [projects];
}

class OfferSubmissionInProgress extends NewProjectsState {
  const OfferSubmissionInProgress();
}

class OfferSubmissionSuccess extends NewProjectsState {
  const OfferSubmissionSuccess({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class OfferSubmissionFailure extends NewProjectsState {
  const OfferSubmissionFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
