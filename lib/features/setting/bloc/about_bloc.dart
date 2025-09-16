import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../repo/about_repo.dart';

class AboutBloc extends Bloc<AppEvent, AppState> {
  final AboutRepo _aboutRepo;

  AboutBloc(this._aboutRepo) : super(Start()) {
    on<Add>(_onGetAbout);
  }

  Future<void> _onGetAbout(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final about = await _aboutRepo.getAboutContent();

      if (about.isEmpty) {
        emit(Error());
      } else {
        emit(Done(data: about));
      }
    } catch (e) {
      log("🔴 Error loading about content: $e");
      emit(Error());
    }
  }
}
