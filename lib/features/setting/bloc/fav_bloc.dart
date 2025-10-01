import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../projects/model/my_projects_model.dart';

class FavBloc extends  Bloc<AppEvent, AppState>{
  final FavouriteRepo _favouriteRepo;
  FavBloc(this._favouriteRepo) : super(Start()){
    on<Add>(_onGetProjects);
  }
  Future<void> _onGetProjects(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final result = await _favouriteRepo.getFavouriteProjects();
      result.fold(
            (failure) => emit(Error()),
            (response) {
              log("response ${response.data}");
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final List<MyProjectsModel> projects =
          (response.data['payload'] as List)
              .map((e) => MyProjectsModel.fromJson(e))
              .toList();
            log("fav projects ${projects}");
          emit(Done(list: projects));
        },
      );
    } catch (_) {
      emit(Error());
    }
  }


}