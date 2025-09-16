import 'package:easy_localization/easy_localization.dart'hide TextDirection;
import 'package:flutter/material.dart';
import 'data/config/di.dart' as di;
import 'data/config/di.dart';
import 'data/local_data/local_database.dart';
import 'navigation/custom_navigation.dart';
import 'navigation/routes.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBM',
      ),

      builder: (context, child) {
        return child!;
      },
    );
  }
}
