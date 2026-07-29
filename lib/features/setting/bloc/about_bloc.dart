import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/about_repository.dart';
import 'static_content_state.dart';

sealed class AboutEvent {
  const AboutEvent();
}

final class AboutRequested extends AboutEvent {
  const AboutRequested();
}

class AboutBloc extends Bloc<AboutEvent, StaticContentState> {
  AboutBloc({required AboutRepository repository})
      : _repository = repository,
        super(const StaticContentInitial()) {
    on<AboutRequested>(_onRequested);
  }

  final AboutRepository _repository;

  Future<void> _onRequested(
    AboutRequested event,
    Emitter<StaticContentState> emit,
  ) async {
    emit(const StaticContentLoading());
    final result = await _repository.getAboutContent();
    result.fold(
      (failure) => emit(StaticContentFailed(failure.error)),
      (html) => emit(StaticContentLoaded(html)),
    );
  }
}
