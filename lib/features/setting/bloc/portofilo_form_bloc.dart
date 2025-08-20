import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart' show AppEvent;
import '../../../app/core/app_state.dart';

class SinglePortfolioData {
  final String title, description, features, clientLink;
  const SinglePortfolioData({this.title = '', this.description = '', this.features = '', this.clientLink = ''});
  SinglePortfolioData copyWith({String? title, String? description, String? features, String? clientLink}) {
    return SinglePortfolioData(
      title: title ?? this.title,
      description: description ?? this.description,
      features: features ?? this.features,
      clientLink: clientLink ?? this.clientLink,
    );
  }
}

class PortfolioFormsState {
  final List<SinglePortfolioData> forms;
  final int expandedFormIndex;
  // --- MODIFICATION: Two booleans for the terms ---
  final bool termsOneAccepted;
  final bool termsTwoAccepted;

  const PortfolioFormsState({
    required this.forms,
    this.expandedFormIndex = 0,
    this.termsOneAccepted = false, // Default to false
    this.termsTwoAccepted = false, // Default to false
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
  final int formIndex; final String fieldName; final dynamic value;
  UpdateFormField({required this.formIndex, required this.fieldName, required this.value});
}

class ExpandForm extends AppEvent {
  final int formIndex;
  ExpandForm({required this.formIndex});
}

// --- NEW EVENT: To update a single term checkbox ---
class UpdateSingleTerm extends AppEvent {
  final int termIndex; // 1 or 2
  final bool isAccepted;
  UpdateSingleTerm({required this.termIndex, required this.isAccepted});
}

class SubmitAllPortfolios extends AppEvent {}

// --- The BLoC ---
class PortfolioFormBloc extends Bloc<AppEvent, AppState> {
  PortfolioFormBloc()
      : super(Done(data: PortfolioFormsState(forms: List.generate(3, (_) => const SinglePortfolioData())))) {
    on<UpdateFormField>(_onUpdateFormField);
    on<ExpandForm>(_onExpandForm);
    on<UpdateSingleTerm>(_onUpdateSingleTerm); // Register new handler
    on<SubmitAllPortfolios>(_onSubmitAllPortfolios);
  }

  void _onUpdateFormField(UpdateFormField event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    final newFormsList = List<SinglePortfolioData>.from(currentState.forms);
    final oldFormData = newFormsList[event.formIndex];
    SinglePortfolioData newFormData;
    switch (event.fieldName) {
      case 'title': newFormData = oldFormData.copyWith(title: event.value); break;
      case 'description': newFormData = oldFormData.copyWith(description: event.value); break;
      case 'features': newFormData = oldFormData.copyWith(features: event.value); break;
      case 'clientLink': newFormData = oldFormData.copyWith(clientLink: event.value); break;
      default: return;
    }
    newFormsList[event.formIndex] = newFormData;
    emit(Done(data: currentState.copyWith(forms: newFormsList)));
  }

  void _onExpandForm(ExpandForm event, Emitter<AppState> emit) {
    if (state is! Done) return;
    final currentState = (state as Done).data as PortfolioFormsState;
    emit(Done(data: currentState.copyWith(expandedFormIndex: event.formIndex)));
  }

  // --- NEW HANDLER: For the new term event ---
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
    emit(Loading());

    if (!currentState.termsOneAccepted || !currentState.termsTwoAccepted) {
      print("Validation Failed: All terms must be accepted.");
      emit(Done(data: currentState));
      return;
    }

    print("Submitting all portfolios...");
    await Future.delayed(const Duration(seconds: 2));
    print("All forms submitted successfully!");
    emit(Done(data: currentState, reload: true));
  }
}