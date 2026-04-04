import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/model/chats_model.dart';
import 'package:talent_flow/features/setting/repo/chats_repo.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';

class ChatsBloc extends Bloc<AppEvent, AppState> {
  final ChatsRepo _chatsRepo;
  Map<int, String> projectOptions = {};

  ChatsBloc(this._chatsRepo) : super(Start()) {
    on<Add>(_onGetChats);
    on<Click>(_onLoadProjectOptions);
  }

  Future<void> _onLoadProjectOptions(Click event, Emitter<AppState> emit) async {
    try {
      final result = await _chatsRepo.getProjectChatOptions();
      result.fold(
        (failure) {
          log("Project options error: $failure");
        },
        (response) {
          try {
            if (response.data is Map && response.data['payload'] is Map) {
              final payload = response.data['payload'] as Map;
              final options = <int, String>{};
              
              payload.forEach((key, value) {
                final id = int.tryParse(key.toString());
                if (id != null && value is String) {
                  options[id] = value;
                }
              });
              
              projectOptions = options;
              // Emit current state to trigger UI rebuild with new project options
              emit(state);
            }
          } catch (e) {
            log("Error parsing project options: $e");
          }
        },
      );
    } catch (e, s) {
      log("Exception loading project options", error: e, stackTrace: s);
    }
  }

  Future<void> _onGetChats(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final args = event.arguments;
      final search = args is Map ? (args['search']?.toString() ?? '') : '';
      final projectIdRaw = args is Map ? args['project_id'] : null;
      final int? projectId = projectIdRaw is int
          ? projectIdRaw
          : int.tryParse(projectIdRaw?.toString() ?? '');

      final result = await _chatsRepo.getChats(
        search: search,
        projectId: projectId,
      );
      result.fold(
        (failure) {
          log("Chats error: $failure");
          emit(Error());
        },
        (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final payload = response.data['payload'];
          if (payload is! List) {
            emit(Error());
            return;
          }

          final List<ChatsModel> chats = payload
              .whereType<Map<String, dynamic>>()
              .map(ChatsModel.fromJson)
              .toList();

          emit(Done(list: chats));
        },
      );
    } catch (e, s) {
      log("Exception in ChatsBloc", error: e, stackTrace: s);
      emit(Error());
    }
  }
}
