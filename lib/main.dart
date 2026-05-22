import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/data/realtime/user_channel_realtime_service.dart'
    as data_realtime;
import 'app/core/styles.dart';
import 'app/notifications/notification_helper.dart';
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
  await FirebaseNotifications.setUpFirebase();

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
        return BlocProvider.value(
          value: userBloc,
          child: _RealtimeSessionBootstrap(child: child!),
        );
      },
    );
  }
}

class _RealtimeSessionBootstrap extends StatefulWidget {
  const _RealtimeSessionBootstrap({required this.child});

  final Widget child;

  @override
  State<_RealtimeSessionBootstrap> createState() =>
      _RealtimeSessionBootstrapState();
}

class _RealtimeSessionBootstrapState extends State<_RealtimeSessionBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant _RealtimeSessionBootstrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleSync();
    }
  }

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      sl<data_realtime.UserChannelRealtimeService>()
          .syncSessionSubscription();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSync();
    return widget.child;
  }
}
