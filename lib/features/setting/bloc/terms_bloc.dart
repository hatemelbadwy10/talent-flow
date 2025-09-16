import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../repo/terms_condation_repo.dart';

class TermsBloc extends Bloc<AppEvent, AppState> {
  final TermsAndConditionRepo _termsRepo;

  TermsBloc(this._termsRepo) : super(Start()) {
    on<Add>(_onGetTerms);
  }

  Future<void> _onGetTerms(
      Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final terms = await _termsRepo.getTermsAndCondition();

      if (terms.isEmpty) {
        emit(Error());
      } else {
        emit(Done(data: terms));
      }
    } catch (e) {
      log("🔴 Error loading terms: $e");
      emit(Error());
    }
  }
}
