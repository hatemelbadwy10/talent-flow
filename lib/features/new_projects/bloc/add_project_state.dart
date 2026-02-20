
import 'dart:io';

import 'package:equatable/equatable.dart';

import '../repo/add_project_repo.dart';

class AddProjectState extends Equatable {
  final int? specializationId;
  final String? specializationName;
  final String title;
  final String description;
  final String? filesDescription;
  final List<String> similarProjects;
  final String? requiredToBeReceived;
  final List<int> skills;
  final List<String>? selectedSkills ; // Add this field to store selected skills <String>
  final String? budget;
  final int? duration;
  final List<ProjectQuestion> questions;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;
  final List<File> files;


  const AddProjectState({
    this.specializationId,
    this.specializationName,
    this.selectedSkills,
    this.title = '',
    this.description = '',
    this.filesDescription,
    this.similarProjects = const [],
    this.files = const [],
    this.requiredToBeReceived = "",
    this.skills = const [],
    this.budget,
    this.duration,
    this.questions = const [],
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  AddProjectState copyWith({
    int? specializationId,
    String? specializationName,
    String? title,
    String? description,
    String? filesDescription,
    List<String>? similarProjects,
    String? requiredToBeReceived,
    List<int>? skills,
    List<String>? selectedSkills,
    String? budget,
    int? duration,
    List<ProjectQuestion>? questions,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    List<File>?files

  }) {
    return AddProjectState(
      specializationId: specializationId ?? this.specializationId,
      specializationName: specializationName ?? this.specializationName,
      title: title ?? this.title,
      description: description ?? this.description,
      filesDescription: filesDescription ?? this.filesDescription,
      similarProjects: similarProjects ?? this.similarProjects,
      requiredToBeReceived: requiredToBeReceived ?? this.requiredToBeReceived,
      skills: skills ?? this.skills,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      budget: budget ?? this.budget,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage ?? this.errorMessage,
      files:  files??this.files
    );
  }

  @override
  List<Object?> get props => [
    specializationId,
    specializationName,
    title,
    description,
    filesDescription,
    similarProjects,
    requiredToBeReceived,
    skills,
    selectedSkills,
    budget,
    duration,
    questions,
    isSubmitting,
    isSubmitted,
    errorMessage,
  ];
}
