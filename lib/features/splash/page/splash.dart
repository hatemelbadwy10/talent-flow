import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/images.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../bloc/splash_bloc.dart';
import '../repo/splash_repo.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      SplashBloc(repo: sl<SplashRepo>())
        ..add(Click()),
      child: BlocBuilder<SplashBloc, AppState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              // This makes the container fill the entire screen
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Images.splash),
                  // This ensures the image covers the whole screen
                  fit: BoxFit.cover,
                ),
              ),
            )
            // Animate the container that holds the background image
                .animate()
            // Apply only the shimmer effect
                .shimmer(
              duration: 1500.ms, // You can adjust the duration
              curve: Curves.easeInOut,
            ),
          );
        },
      ),
    );
  }
}