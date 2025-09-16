import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../repo/splash_repo.dart';

class SplashBloc extends Bloc<AppEvent, AppState> {
  final SplashRepo repo;

  SplashBloc({required this.repo}) : super(Start()) {
    on<Click>(onClick);
  }

  Future<void> onClick(AppEvent event, Emitter<AppState> emit) async {
    Future.delayed(const Duration(milliseconds: 2200), () async {
      log("repo.isFirstTime ${repo.isFirstTime}");

      /// 1. Check if it's the user's first time.
      if (repo.isFirstTime) {
        // It's the first time, so mark it as not the first time for future launches.
        repo.setFirstTime();
        // Navigate to Onboarding and clear the navigation stack.
        CustomNavigator.push(Routes.onBoarding, clean: true);
      } else {
        // /// 2. If not the first time, check if the user is logged in.
        // if (repo.isLogin) {
        //   // If logged in, fetch user data and go to the dashboard.
        //   UserBloc.instance.add(Click()); // Assuming this fetches user details
        //   CustomNavigator.push(Routes.home, clean: true, arguments: 0);
        // } else {
        final routes =
            sl<SharedPreferences>().getBool(AppStorageKey.isLogin) ?? false
                ? Routes.navBar
                : Routes.login;
        CustomNavigator.push(routes, clean: true);
      }
    });
  }
}
