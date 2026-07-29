import 'package:flutter_bloc/flutter_bloc.dart';

import '../repo/favourites_repository.dart';
import 'fav_event.dart';
import 'fav_state.dart';

class FavBloc extends Bloc<FavouriteEvent, FavouriteState> {
  FavBloc({required FavouritesRepository repository})
      : _repository = repository,
        super(const FavouriteInitial()) {
    on<FavouritesRequested>(_onRequested);
    on<FavouriteToggled>(_onToggled);
  }

  final FavouritesRepository _repository;

  Future<void> _onRequested(
    FavouritesRequested event,
    Emitter<FavouriteState> emit,
  ) async {
    await _fetchFavourites(emit, withLoading: true);
  }

  Future<void> _onToggled(
    FavouriteToggled event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(const FavouriteLoading());
    final result = switch (event.type) {
      FavouriteType.project =>
        await _repository.toggleProjectFavourite(event.id),
      FavouriteType.freelancer =>
        await _repository.toggleFreelancerFavourite(event.id),
      FavouriteType.work => await _repository.toggleWorkFavourite(event.id),
    };
    await result.fold(
      (failure) async => emit(FavouriteFailed(failure.error)),
      (_) async => _fetchFavourites(emit, withLoading: false),
    );
  }

  Future<void> _fetchFavourites(
    Emitter<FavouriteState> emit, {
    required bool withLoading,
  }) async {
    if (withLoading) {
      emit(const FavouriteLoading());
    }
    final result = await _repository.getFavourites();
    result.fold(
      (failure) => emit(FavouriteFailed(failure.error)),
      (favourites) => emit(FavouriteLoaded(favourites)),
    );
  }
}
