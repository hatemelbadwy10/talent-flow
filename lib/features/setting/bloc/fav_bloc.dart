import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';

class FavBloc extends Bloc<AppEvent, AppState> {
  final FavouriteRepo _favouriteRepo;

  FavBloc(this._favouriteRepo) : super(Start()) {
    on<Add>(_onGetProjects);
    on<Update>(_onToggleFavourite);
  }

  Future<void> _onGetProjects(Add event, Emitter<AppState> emit) async {
    await _fetchFavourites(emit: emit, withLoading: true);
  }

  Future<void> _onToggleFavourite(Update event, Emitter<AppState> emit) async {
    final args = event.arguments;
    final map =
        args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    final type = map['type']?.toString();
    final id = map['id'] is int
        ? map['id'] as int
        : int.tryParse(map['id']?.toString() ?? '');

    if (id == null || type == null) {
      return;
    }

    if (emit.isDone) {
      return;
    }
    emit(Loading());

    try {
      late final dynamic result;
      if (type == 'project') {
        result = await _favouriteRepo.toggleProjectFavourite(id);
      } else if (type == 'freelancer') {
        result = await _favouriteRepo.toggleFreelancerFavourite(id);
      } else if (type == 'work') {
        result = await _favouriteRepo.toggleWorkFavourite(id);
      } else {
        if (!emit.isDone) {
          emit(Error());
        }
        return;
      }

      await result.fold(
        (failure) async {
          log("Favourite toggle error: ${failure.error}");
          if (!emit.isDone) {
            emit(Error());
          }
        },
        (_) async => _fetchFavourites(emit: emit, withLoading: false),
      );
    } catch (e, s) {
      log("Exception in FavBloc toggle", error: e, stackTrace: s);
      if (!emit.isDone) {
        emit(Error());
      }
    }
  }

  Future<void> _fetchFavourites({
    required Emitter<AppState> emit,
    required bool withLoading,
  }) async {
    if (emit.isDone) {
      return;
    }
    if (withLoading) {
      emit(Loading());
    }

    try {
      final result = await _favouriteRepo.getFavourites();
      await result.fold(
        (failure) async {
          log("Favourite error: ${failure.error}");
          if (!emit.isDone) {
            emit(Error());
          }
        },
        (response) async {
          if (!emit.isDone) {
            emit(Done(model: response));
          }
        },
      );
    } catch (e, s) {
      log("Exception in FavBloc", error: e, stackTrace: s);
      if (!emit.isDone) {
        emit(Error());
      }
    }
  }
}
