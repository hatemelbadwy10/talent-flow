import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'app/core/app_event.dart';
import 'app/core/app_state.dart';
import 'app/core/styles.dart';
import 'data/config/di.dart' as di;
import 'data/config/di.dart';
import 'data/local_data/local_database.dart';
import 'firebase_options.dart';
import 'navigation/custom_navigation.dart';
import 'navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();
  await di.init();
  await sl<LocaleDatabase>().initDatabase();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      path: 'assets/language',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      navigatorKey: CustomNavigator.navigatorState,
      scaffoldMessengerKey: CustomNavigator.scaffoldState,
      onGenerateRoute: CustomNavigator.onCreateRoute,
      navigatorObservers: [CustomNavigator.routeObserver],
      initialRoute: Routes.splash,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(surfaceTintColor: Colors.white),
        cardColor: Colors.white,
        tabBarTheme:
            const TabBarThemeData(indicatorColor: Styles.PRIMARY_COLOR),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBM',
      ),
      builder: (context, child) {
        final userBloc = UserBloc.instance;
        if (userBloc.isLogin &&
            userBloc.user == null &&
            userBloc.state is Start) {
          userBloc.add(Click());
        }
        return BlocProvider.value(
          value: userBloc,
          child: child!,
        );
      },
    );
  }
}
