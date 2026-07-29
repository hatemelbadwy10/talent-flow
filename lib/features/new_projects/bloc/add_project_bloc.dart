import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/project_question.dart';
import '../repo/add_project_repository.dart';
import 'add_project_event.dart';
import 'add_project_state.dart';

class AddProjectBloc extends Bloc<AddProjectEvent, AddProjectState> {
  final AddProjectRepository _repository;

  AddProjectBloc({required AddProjectRepository repository})
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

  void _onUpdateSpecializationId(
      UpdateSpecializationId event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(
        specializationId: event.specializationId,
        specializationName: event.specializationName));
  }

  void _onUpdateTitle(UpdateTitle event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onUpdateDescription(
      UpdateDescription event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onUpdateFilesDescription(
      UpdateFilesDescription event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(filesDescription: event.filesDescription));
  }

  void _onUpdateSimilarProjects(
      UpdateSimilarProjects event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(similarProjects: event.similarProjects));
  }

  void _onUpdateRequiredToBeReceived(
      UpdateRequiredToBeReceived event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(requiredToBeReceived: event.requiredToBeReceived));
  }

  void _onUpdateFiles(UpdateFiles event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(files: event.files));
  }

  void _onUpdateSkills(UpdateSkills event, Emitter<AddProjectState> emit) {
    emit(
        state.copyWith(skills: event.skills, selectedSkills: event.skillNames));
  }

  void _onUpdateBudget(UpdateBudget event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(budget: event.budget));
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AddProjectState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onAddQuestion(AddQuestion event, Emitter<AddProjectState> emit) {
    final updatedQuestions = List<ProjectQuestion>.from(state.questions)
      ..add(event.question);
    emit(state.copyWith(questions: updatedQuestions));
  }

  void _onUpdateQuestion(UpdateQuestion event, Emitter<AddProjectState> emit) {
    final updatedQuestions = List<ProjectQuestion>.from(state.questions);
    if (event.index >= 0 && event.index < updatedQuestions.length) {
      updatedQuestions[event.index] = event.question;
      emit(state.copyWith(questions: updatedQuestions));
    }
  }

  void _onRemoveQuestion(RemoveQuestion event, Emitter<AddProjectState> emit) {
    final updatedQuestions = List<ProjectQuestion>.from(state.questions);
    if (event.index >= 0 && event.index < updatedQuestions.length) {
      updatedQuestions.removeAt(event.index);
      emit(state.copyWith(questions: updatedQuestions));
    }
  }

  Future<void> _onSubmitProject(
      SubmitProject event, Emitter<AddProjectState> emit) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        isSubmitted: false,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await _repository.addProject(
        specializationId: state.specializationId!,
        title: state.title,
        description: state.description,
        skills: state.skills,
        budget: state.budget!,
        duration: state.duration!,
        files: state.files.isNotEmpty ? state.files : null,
        filesDescription: state.filesDescription,
        similarProjects:
            state.similarProjects.isNotEmpty ? state.similarProjects : null,
        requiredToBeReceived: state.requiredToBeReceived,
        questions: state.questions.isNotEmpty ? state.questions : null,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isSubmitting: false,
              isSubmitted: false,
              errorMessage: failure.error,
              clearSuccess: true,
            ),
          );
        },
        (message) {
          emit(
            state.copyWith(
              isSubmitting: false,
              isSubmitted: true,
              successMessage: message,
              clearError: true,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        isSubmitted: false,
        errorMessage: e.toString(),
        clearSuccess: true,
      ));
    }
  }

  void _onResetForm(ResetForm event, Emitter<AddProjectState> emit) {
    emit(const AddProjectState());
  }
}
