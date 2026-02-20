import 'dart:io';

import 'package:equatable/equatable.dart';

import '../repo/add_project_repo.dart';

abstract class AddProjectEvent extends Equatable {
  const AddProjectEvent();

  @override
  List<Object?> get props => [];
}

class UpdateSpecializationId extends AddProjectEvent {
  final int? specializationId;
  final String? specializationName;


  const UpdateSpecializationId({this.specializationId,this.specializationName});

  @override
  List<Object?> get props => [specializationId];
}

class UpdateTitle extends AddProjectEvent {
  final String title;

  const UpdateTitle({required this.title});

  @override
  List<Object?> get props => [title];
}

class UpdateDescription extends AddProjectEvent {
  final String description;

  const UpdateDescription({required this.description});

  @override
  List<Object?> get props => [description];
}

class UpdateFiles extends AddProjectEvent {
  final List<File> files;

  const UpdateFiles({required this.files});

  @override
  List<Object?> get props => [files];
}

class UpdateFilesDescription extends AddProjectEvent {
  final String? filesDescription;

  const UpdateFilesDescription({this.filesDescription});

  @override
  List<Object?> get props => [filesDescription];
}

class UpdateSimilarProjects extends AddProjectEvent {
  final List<String> similarProjects;

  const UpdateSimilarProjects({required this.similarProjects});

  @override
  List<Object?> get props => [similarProjects];
}

class UpdateRequiredToBeReceived extends AddProjectEvent {
  final String requiredToBeReceived;

  const UpdateRequiredToBeReceived({required this.requiredToBeReceived});

  @override
  List<Object?> get props => [requiredToBeReceived];
}

class UpdateSkills extends AddProjectEvent {
  final List<int> skills;
  final List<String> skillNames;
  const UpdateSkills({required this.skills,required this.skillNames});

  @override
  List<Object?> get props => [skills];
}

class UpdateBudget extends AddProjectEvent {
  final String? budget;

  const UpdateBudget({this.budget});

  @override
  List<Object?> get props => [budget];
}

class UpdateDuration extends AddProjectEvent {
  final int? duration;

  const UpdateDuration({this.duration});

  @override
  List<Object?> get props => [duration];
}

class AddQuestion extends AddProjectEvent {
  final ProjectQuestion question;

  const AddQuestion({required this.question});

  @override
  List<Object?> get props => [question];
}

class UpdateQuestion extends AddProjectEvent {
  final int index;
  final ProjectQuestion question;

  const UpdateQuestion({required this.index, required this.question});

  @override
  List<Object?> get props => [index, question];
}

class RemoveQuestion extends AddProjectEvent {
  final int index;

  const RemoveQuestion({required this.index});

  @override
  List<Object?> get props => [index];
}

class SubmitProject extends AddProjectEvent {}

class ResetForm extends AddProjectEvent {}
