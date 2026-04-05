import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/selection_option_repo.dart';
import 'selection_option_event.dart';
import 'selection_option_state.dart';

class SelectionOptionBloc
    extends Bloc<SelectionOptionEvent, SelectionOptionState> {
  final SelectionOptionRepo _selectionOptionRepo;

  SelectionOptionBloc(this._selectionOptionRepo)
      : super(const SelectionOptionInitial()) {
    on<SelectionOptionsRequested>(_getSelectionOption);
  }

  Future<void> _getSelectionOption(
    SelectionOptionsRequested event,
    Emitter<SelectionOptionState> emit,
  ) async {
    emit(const SelectionOptionLoading());
    final result = await _selectionOptionRepo.getSelectionOption();

    result.fold(
      (failure) => emit(SelectionOptionFailure(message: failure.error)),
      (response) => emit(SelectionOptionLoaded(response)),
    );
  }
}
