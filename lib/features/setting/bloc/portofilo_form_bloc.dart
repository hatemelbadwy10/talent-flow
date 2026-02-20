import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/repo/add_word_repo.dart';

import 'dart:io';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';

class SinglePortfolioData {
  final String title;
  final String description;
  final String features;
  final String clientLink;
  final String date;
  final File? image;
  final List<File> files;

  const SinglePortfolioData({
    this.title = '',
    this.description = '',
    this.features = '',
    this.clientLink = '',
    this.date = '',
    this.image,
    this.files = const [],
  });

  SinglePortfolioData copyWith({
    String? title,
    String? description,
    String? features,
    String? clientLink,
    String? date,
    File? image,
    List<File>? files,
  }) {
    return SinglePortfolioData(
      title: title ?? this.title,
      description: description ?? this.description,
      features: features ?? this.features,
      clientLink: clientLink ?? this.clientLink,
      date: date ?? this.date,
      image: image ?? this.image,
      files: files ?? this.files,
    );
  }

  WorkItem toWorkItem() {
    return WorkItem(
      title: title,
      description: description,
      date: date,
      previewLink: clientLink,
      image: image,
      files: files,
    );
  }
}

class PortfolioFormsState {
  final List<SinglePortfolioData> forms;
  final int expandedFormIndex;
  final bool termsOneAccepted;
  final bool termsTwoAccepted;

  const PortfolioFormsState({
    required this.forms,
    this.expandedFormIndex = 0,
    this.termsOneAccepted = false,
    this.termsTwoAccepted = false,
  });

  PortfolioFormsState copyWith({
    List<SinglePortfolioData>? forms,
    int? expandedFormIndex,
    bool? termsOneAccepted,
    bool? termsTwoAccepted,
  }) {
    return PortfolioFormsState(
      forms: forms ?? this.forms,
      expandedFormIndex: expandedFormIndex ?? this.expandedFormIndex,
      termsOneAccepted: termsOneAccepted ?? this.termsOneAccepted,
      termsTwoAccepted: termsTwoAccepted ?? this.termsTwoAccepted,
    );
  }
}

// --- Events ---
class UpdateFormField extends AppEvent {
  final int formIndex;
  final String fieldName;
  final dynamic value;
  UpdateFormField({required this.formIndex, required this.fieldName, required this.value});
}

class UpdateFormImage extends AppEvent {
  final int formIndex;
  final File image;
  UpdateFormImage({required this.formIndex, required this.image});
}

class UpdateFormFiles extends AppEvent {
  final int formIndex;
  final List<File> files;
  UpdateFormFiles({required this.formIndex, required this.files});
}

class RemoveFormFile extends AppEvent {
  final int formIndex;
  final int fileIndex;
  RemoveFormFile({required this.formIndex, required this.fileIndex});
}

class ExpandForm extends AppEvent {
  final int formIndex;
  ExpandForm({required this.formIndex});
}

class UpdateSingleTerm extends AppEvent {
  final int termIndex;
  final bool isAccepted;
  UpdateSingleTerm({required this.termIndex, required this.isAccepted});
}

class SubmitAllPortfolios extends AppEvent {}

// --- The BLoC ---
class PortfolioFormBloc extends Bloc<AppEvent, AppState> {
  final AddWorkRepo workRepo;
  PortfolioFormBloc(this.workRepo)
      : super(Done(data: PortfolioFormsState(forms: List.generate(3, (_) => const SinglePortfolioData())))) {
    on<UpdateFormField>(_onUpdateFormField);
    on<UpdateFormImage>(_onUpdateFormImage);
    on<UpdateFormFiles>(_onUpdateFormFiles);
    on<RemoveFormFile>(_onRemoveFormFile);
    on<ExpandForm>(_onExpandForm);
    on<UpdateSingleTerm>(_onUpdateSingleTerm);
    on<SubmitAllPortfolios>(_onSubmitAllPortfolios);
  }

  void _onUpdateFormField(UpdateFormField event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];
    SinglePortfolioData newFormData;

    switch (event.fieldName) {
      case 'title':
        newFormData = oldFormData.copyWith(title: event.value);
        break;
      case 'description':
        newFormData = oldFormData.copyWith(description: event.value);
        break;
      case 'features':
        newFormData = oldFormData.copyWith(features: event.value);
        break;
      case 'clientLink':
        newFormData = oldFormData.copyWith(clientLink: event.value);
        break;
      case 'date':
        newFormData = oldFormData.copyWith(date: event.value);
        break;
      default:
        return;
    }

    newFormsList[event.formIndex] = newFormData;
    emit(Done(data: currentState.copyWith(forms: newFormsList)));
  }

  void _onUpdateFormImage(UpdateFormImage event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];

    final newFormData = oldFormData.copyWith(image: event.image);
    newFormsList[event.formIndex] = newFormData;
    emit(Done(data: currentState.copyWith(forms: newFormsList)));
  }

  void _onUpdateFormFiles(UpdateFormFiles event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];

    // Add new files to existing ones
    final updatedFiles = List<File>.from(oldFormData.files)..addAll(event.files);

    final newFormData = oldFormData.copyWith(files: updatedFiles);
    newFormsList[event.formIndex] = newFormData;
    emit(Done(data: currentState.copyWith(forms: newFormsList)));
  }

  void _onRemoveFormFile(RemoveFormFile event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];

    // Remove the file at the specified index
    final updatedFiles = List<File>.from(oldFormData.files)..removeAt(event.fileIndex);

    final newFormData = oldFormData.copyWith(files: updatedFiles);
    newFormsList[event.formIndex] = newFormData;
    emit(Done(data: currentState.copyWith(forms: newFormsList)));
  }

  void _onExpandForm(ExpandForm event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    emit(Done(data: currentState.copyWith(expandedFormIndex: event.formIndex)));
  }

  void _onUpdateSingleTerm(UpdateSingleTerm event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    if (event.termIndex == 1) {
      emit(Done(data: currentState.copyWith(termsOneAccepted: event.isAccepted)));
    } else if (event.termIndex == 2) {
      emit(Done(data: currentState.copyWith(termsTwoAccepted: event.isAccepted)));
    }
  }

  void _onSubmitAllPortfolios(SubmitAllPortfolios event, Emitter<AppState> emit) async {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;

    // Check if terms are accepted
    if (!currentState.termsOneAccepted || !currentState.termsTwoAccepted) {
      print("Validation Failed: All terms must be accepted.");
      emit(Done(data: currentState));
      return;
    }

    emit(Loading());

    // Convert SinglePortfolioData → WorkItem
    final works = currentState.forms.map((form) => form.toWorkItem()).toList();

    final response = await workRepo.addWorks(works: works);

    response.fold(
          (failure) {
        print("Error: ${failure}");
        emit(Done(data: currentState));
      },
          (success) {
        print("All forms submitted successfully!");
        emit(Done(data: currentState, reload: true));
      },
    );
  }
}