import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/features/setting/repo/settings_repo.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import '../model/help_model.dart';

class SettingsBloc extends Bloc<AppEvent, AppState> {
  final SettingsRepo _settingsRepo;

  SettingsBloc(this._settingsRepo) : super(Start()) {
    on<Click>(_onHelp);
    on<Add>(_onLogout);
  }

  Future<void> _onHelp(Click event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final result = await _settingsRepo.help(event.arguments as HelpModel);
      result.fold(
        (failure) => emit(Error()),
        (response) {
          log("Help response: ${response.data}");
          emit(Done(data: response.data));
        },
      );
    } catch (e) {
      emit(Error());
    }
  }

  Future<void> _onLogout(Add event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final result = await _settingsRepo.logout();
      result.fold(
        (failure) => emit(Error()),
        (response) {
          final isFirstTime =
              sl<SharedPreferences>().getBool(AppStorageKey.notFirstTime);
          sl<SharedPreferences>().clear();
          sl<SharedPreferences>()
              .setBool(AppStorageKey.notFirstTime, isFirstTime ?? true);

          CustomNavigator.push(Routes.login, clean: true); // then navigate

          log("Logout response: ${response.data}");
          emit(Done(data: response.data));
        },
      );
    } catch (e) {
      emit(Error());
    }
  }
}
