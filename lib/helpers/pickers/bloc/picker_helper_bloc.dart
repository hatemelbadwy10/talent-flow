import 'dart:io';

import 'package:talent_flow/helpers/pickers/repo/picker_helper_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/core/app_core.dart';
import '../../../../app/core/app_event.dart';
import '../../../../app/core/app_state.dart';
import '../../../../data/error/failures.dart';
import '../model/picker_model.dart';

class PickerHelperBloc extends Bloc<AppEvent, AppState> {
  final PickerHelperRepo repo;
  PickerHelperBloc({required this.repo}) : super(Start()) {
    on<Click>(onClick);
  }

  Future<void> onClick(Click event, Emitter<AppState> emit) async {
    try {
      emit(Loading(progress: 0, total: 100));

      Map<String, dynamic> arguments =
          (event.arguments as Map<String, dynamic>);
      Map<String, dynamic> data = {
        "attachment_type": arguments["attachment_type"] as String,
        "model": arguments["model"] as String,
        "file": MultipartFile.fromFileSync((arguments["file"] as File).path)
      };

      Either<ServerFailure, Response> response = await repo.uploadFile(
        data: data,
        onReceiveProgress: (progress, total) {
          emit(Loading(
              progress: ((progress.abs() / total.abs()) * 100).floor(),
              total: 100));
          // if (total.abs() >= 100) {
          //   emit(Done());
          // }
        },
      );

      response.fold((fail) {
        AppCore.showToast(fail.error);
        emit(Error());
      }, (success) {
        PickerModel model = PickerModel(
            url: success.data["data"] ??
                "https://www.youtube.com/watch?v=yOx2JBeOzkk",
            file: (arguments["file"] as File));
        (arguments["onSuccess"] as Function(PickerModel)).call(model);
        emit(Done());
      });
    } catch (e) {
      AppCore.showToast(e.toString());
      emit(Error());
    }
  }
}
