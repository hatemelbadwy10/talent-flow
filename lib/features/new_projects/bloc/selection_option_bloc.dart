import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/selection_options_repository.dart';
import 'selection_option_event.dart';
import 'selection_option_state.dart';

class SelectionOptionBloc
    extends Bloc<SelectionOptionEvent, SelectionOptionState> {
  final SelectionOptionsRepository _repository;

  SelectionOptionBloc({required SelectionOptionsRepository repository})
      : _repository = repository,
        super(const SelectionOptionInitial()) {
    on<SelectionOptionsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    SelectionOptionsRequested event,
    Emitter<SelectionOptionState> emit,
  ) async {
    emit(const SelectionOptionLoading());
    final result = await _repository.getSelectionOptions();
    result.fold(
      (failure) => emit(SelectionOptionFailed(failure.error)),
      (options) => emit(SelectionOptionLoaded(options)),
    );
  }
}
