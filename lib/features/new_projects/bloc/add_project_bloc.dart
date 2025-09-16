// bloc/add_project/add_project_bloc.dart
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../repo/add_project_repo.dart';
import 'add_project_event.dart';
import 'add_project_state.dart';

class AddProjectBloc extends Bloc<AddProjectEvent, AddProjectState> {
  final ProjectRepository _repository;

  AddProjectBloc({required ProjectRepository repository})
      : _repository = repository,
        super(const AddProjectState()) {

    on<UpdateSpecializationId>(_onUpdateSpecializationId);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateDescription>(_onUpdateDescription);
    on<UpdateFilesDescription>(_onUpdateFilesDescription);
    on<UpdateSimilarProjects>(_onUpdateSimilarProjects);
    on<UpdateRequiredToBeReceived>(_onUpdateRequiredToBeReceived);
    on<UpdateSkills>(_onUpdateSkills);
    on<UpdateBudget>(_onUpdateBudget);
    on<UpdateDuration>(_onUpdateDuration);
    on<AddQuestion>(_onAddQuestion);
    on<UpdateQuestion>(_onUpdateQuestion);
    on<RemoveQuestion>(_onRemoveQuestion);
    on<SubmitProject>(_onSubmitProject);
    on<UpdateFiles>(_onUpdateFiles);
    on<ResetForm>(_onResetForm);
  }

  void _onUpdateSpecializationId(UpdateSpecializationId event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(specializationId: event.specializationId,specializationName: event.specializationName));
  }

  void _onUpdateTitle(UpdateTitle event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(title: event.title));
  }

  void _onUpdateDescription(UpdateDescription event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(description: event.description));
  }

  void _onUpdateFilesDescription(UpdateFilesDescription event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(filesDescription: event.filesDescription));
  }

  void _onUpdateSimilarProjects(UpdateSimilarProjects event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(similarProjects: event.similarProjects));
  }

  void _onUpdateRequiredToBeReceived(UpdateRequiredToBeReceived event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(requiredToBeReceived: event.requiredToBeReceived));
  }
  void _onUpdateFiles(UpdateFiles event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(files: event.files));
  }


  void _onUpdateSkills(UpdateSkills event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(skills: event.skills,selectedSkills: event.skillNames));
  }


  void _onUpdateBudget(UpdateBudget event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(budget: event.budget));
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(duration: event.duration));
  }

  void _onAddQuestion(AddQuestion event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    final updatedQuestions = List<ProjectQuestion>.from(state.questions)
      ..add(event.question);
    emit(state.copyWith(questions: updatedQuestions));
  }

  void _onUpdateQuestion(UpdateQuestion event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    final updatedQuestions = List<ProjectQuestion>.from(state.questions);
    if (event.index >= 0 && event.index < updatedQuestions.length) {
      updatedQuestions[event.index] = event.question;
      emit(state.copyWith(questions: updatedQuestions));
    }
  }

  void _onRemoveQuestion(RemoveQuestion event, Emitter<AddProjectState> emit) {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    final updatedQuestions = List<ProjectQuestion>.from(state.questions);
    if (event.index >= 0 && event.index < updatedQuestions.length) {
      updatedQuestions.removeAt(event.index);
      emit(state.copyWith(questions: updatedQuestions));
    }
  }

  Future<void> _onSubmitProject(SubmitProject event, Emitter<AddProjectState> emit) async {
    log("specializationId ${state.specializationId}");
    log("title ${state.title}");
    log("description ${state.description}");
    log("skills ${state.skills}");
    log("budget ${state.budget}");
    log("duration ${state.duration}");
    log("filesDescription ${state.filesDescription}");
    log("similarProjects ${state.similarProjects}");
    log("requiredToBeReceived ${state.requiredToBeReceived}");
    log('questions ${state.questions}');
    log('files ${state.files}');

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      log("specializationId ${state.specializationId}");
      log("title ${state.title}");
      log("description ${state.description}");
      log("skills ${state.skills}");
      log("budget ${state.budget}");
      log("duration ${state.duration}");
      log("filesDescription ${state.filesDescription}");
      log("similarProjects ${state.similarProjects}");
      log("requiredToBeReceived ${state.requiredToBeReceived}");
      log('questions ${state.questions}');
      log('files ${state.files}');
      await _repository.addProject(
        specializationId: state.specializationId!,
        title: state.title,
        description: state.description,
        skills: state.skills,
        budget: state.budget!,
        duration: state.duration!,
        filesDescription: state.filesDescription,
        similarProjects: state.similarProjects.isNotEmpty ? state.similarProjects : null,
        requiredToBeReceived: state.requiredToBeReceived,
        questions: state.questions.isNotEmpty ? state.questions : null,
      );

      emit(state.copyWith(isSubmitting: false, isSubmitted: true));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetForm(ResetForm event, Emitter<AddProjectState> emit) {
    emit(const AddProjectState());
  }
}