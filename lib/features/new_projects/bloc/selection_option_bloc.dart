import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import '../repo/selection_option_repo.dart';

class SelectionOptionBloc extends Bloc<AppEvent, AppState> {
  final SelectionOptionRepo _selectionOptionRepo;

  SelectionOptionBloc(this._selectionOptionRepo) : super(Start()) {
    on<Add>(getSelectionOption);
  }

  Future<dynamic> getSelectionOption(Add event, Emitter<AppState> emit) async {
    final result = await _selectionOptionRepo.getSelectionOption();

    return result.fold(
      (failure) => failure,
      (response) => emit(Done(model: response)),
    );
  }
}
