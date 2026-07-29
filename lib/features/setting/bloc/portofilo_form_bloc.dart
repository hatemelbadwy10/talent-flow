import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/model/work_item.dart';
import 'dart:io';

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
sealed class PortfolioFormEvent {
  const PortfolioFormEvent();
}

class UpdateFormField extends PortfolioFormEvent {
  final int formIndex;
  final String fieldName;
  final dynamic value;
  const UpdateFormField(
      {required this.formIndex, required this.fieldName, required this.value});
}

class UpdateFormImage extends PortfolioFormEvent {
  final int formIndex;
  final File image;
  const UpdateFormImage({required this.formIndex, required this.image});
}

class UpdateFormFiles extends PortfolioFormEvent {
  final int formIndex;
  final List<File> files;
  const UpdateFormFiles({required this.formIndex, required this.files});
}

class RemoveFormFile extends PortfolioFormEvent {
  final int formIndex;
  final int fileIndex;
  const RemoveFormFile({required this.formIndex, required this.fileIndex});
}

class ExpandForm extends PortfolioFormEvent {
  final int formIndex;
  const ExpandForm({required this.formIndex});
}

class UpdateSingleTerm extends PortfolioFormEvent {
  final int termIndex;
  final bool isAccepted;
  const UpdateSingleTerm({required this.termIndex, required this.isAccepted});
}

class SubmitAllPortfolios extends PortfolioFormEvent {
  const SubmitAllPortfolios();
}

sealed class PortfolioFormState {
  const PortfolioFormState();
}

class PortfolioFormEditing extends PortfolioFormState {
  const PortfolioFormEditing(this.data);

  final PortfolioFormsState data;
}

class PortfolioFormReadyForSubmission extends PortfolioFormState {
  const PortfolioFormReadyForSubmission(this.data);

  final PortfolioFormsState data;
}

class PortfolioFormBloc extends Bloc<PortfolioFormEvent, PortfolioFormState> {
  PortfolioFormBloc()
      : super(
          PortfolioFormEditing(
            PortfolioFormsState(
              forms: List.generate(3, (_) => const SinglePortfolioData()),
            ),
          ),
        ) {
    on<UpdateFormField>(_onUpdateFormField);
    on<UpdateFormImage>(_onUpdateFormImage);
    on<UpdateFormFiles>(_onUpdateFormFiles);
    on<RemoveFormFile>(_onRemoveFormFile);
    on<ExpandForm>(_onExpandForm);
    on<UpdateSingleTerm>(_onUpdateSingleTerm);
    on<SubmitAllPortfolios>(_onSubmitAllPortfolios);
  }

  PortfolioFormsState get _data => switch (state) {
        PortfolioFormEditing(:final data) => data,
        PortfolioFormReadyForSubmission(:final data) => data,
      };

  void _onUpdateFormField(
    UpdateFormField event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;
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
    emit(PortfolioFormEditing(currentState.copyWith(forms: newFormsList)));
  }

  void _onUpdateFormImage(
    UpdateFormImage event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];

    final newFormData = oldFormData.copyWith(image: event.image);
    newFormsList[event.formIndex] = newFormData;
    emit(PortfolioFormEditing(currentState.copyWith(forms: newFormsList)));
  }

  void _onUpdateFormFiles(
    UpdateFormFiles event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];

    // Add new files to existing ones
    final updatedFiles = List<File>.from(oldFormData.files)
      ..addAll(event.files);

    final newFormData = oldFormData.copyWith(files: updatedFiles);
    newFormsList[event.formIndex] = newFormData;
    emit(PortfolioFormEditing(currentState.copyWith(forms: newFormsList)));
  }

  void _onRemoveFormFile(
    RemoveFormFile event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];

    // Remove the file at the specified index
    final updatedFiles = List<File>.from(oldFormData.files)
      ..removeAt(event.fileIndex);

    final newFormData = oldFormData.copyWith(files: updatedFiles);
    newFormsList[event.formIndex] = newFormData;
    emit(PortfolioFormEditing(currentState.copyWith(forms: newFormsList)));
  }

  void _onExpandForm(
    ExpandForm event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;
    emit(
      PortfolioFormEditing(
        currentState.copyWith(expandedFormIndex: event.formIndex),
      ),
    );
  }

  void _onUpdateSingleTerm(
    UpdateSingleTerm event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;
    if (event.termIndex == 1) {
      emit(
        PortfolioFormEditing(
          currentState.copyWith(termsOneAccepted: event.isAccepted),
        ),
      );
    } else if (event.termIndex == 2) {
      emit(
        PortfolioFormEditing(
          currentState.copyWith(termsTwoAccepted: event.isAccepted),
        ),
      );
    }
  }

  void _onSubmitAllPortfolios(
    SubmitAllPortfolios event,
    Emitter<PortfolioFormState> emit,
  ) {
    final currentState = _data;

    // Check if terms are accepted
    if (!currentState.termsOneAccepted || !currentState.termsTwoAccepted) {
      emit(PortfolioFormEditing(currentState));
      return;
    }

    emit(PortfolioFormReadyForSubmission(currentState));
  }
}
