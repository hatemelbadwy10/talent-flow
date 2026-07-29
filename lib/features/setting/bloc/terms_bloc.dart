import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/terms_repository.dart';
import 'static_content_state.dart';

sealed class TermsEvent {
  const TermsEvent();
}

final class TermsRequested extends TermsEvent {
  const TermsRequested();
}

class TermsBloc extends Bloc<TermsEvent, StaticContentState> {
  TermsBloc({required TermsRepository repository})
      : _repository = repository,
        super(const StaticContentInitial()) {
    on<TermsRequested>(_onRequested);
  }

  final TermsRepository _repository;

  Future<void> _onRequested(
    TermsRequested event,
    Emitter<StaticContentState> emit,
  ) async {
    emit(const StaticContentLoading());
    final result = await _repository.getTermsAndCondition();
    result.fold(
      (failure) => emit(StaticContentFailed(failure.error)),
      (html) => emit(StaticContentLoaded(html)),
    );
  }
}
