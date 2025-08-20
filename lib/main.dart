import 'package:flutter/material.dart';
import 'data/config/di.dart' as di;
import 'data/config/di.dart';
import 'data/local_data/local_database.dart';
import 'navigation/custom_navigation.dart';
import 'navigation/routes.dart';

void main() async{

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await di.init();
  await sl<LocaleDatabase>().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: CustomNavigator.navigatorState,
      onGenerateRoute: CustomNavigator.onCreateRoute,
      navigatorObservers: [CustomNavigator.routeObserver],
      initialRoute: Routes.splash,

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBM',
      ),

    );
  }
}
