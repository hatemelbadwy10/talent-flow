import 'package:talent_flow/components/loading_dialog.dart';
import 'package:talent_flow/helpers/delete_file/repo/delete_file_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../../app/core/app_core.dart';
import '../../../../app/core/app_event.dart';
import '../../../../app/core/app_state.dart';
import '../../../../data/error/failures.dart';

class DeleteFileBloc extends Bloc<AppEvent, AppState> {
  final DeleteFileRepo repo;
  DeleteFileBloc({required this.repo}) : super(Start()) {
    on<Click>(onClick);
  }

  Future<void> onClick(Click event, Emitter<AppState> emit) async {
    try {
      loadingDialog();

      Either<ServerFailure, Response> response =
          await repo.deleteFile((event.arguments as Map)["id"]);
      CustomNavigator.pop();

      response.fold((fail) {
        AppCore.showToast(fail.error);
        emit(Error());
      }, (success) {
        (event.arguments as Map)["onDone"].call();
        CustomNavigator.pop();
        emit(Done());
      });
    } catch (e) {
      CustomNavigator.pop();

      AppCore.showToast(e.toString());
      emit(Error());
    }
  }
}
