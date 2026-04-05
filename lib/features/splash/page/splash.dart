import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/images.dart';
import 'package:talent_flow/app/core/styles.dart';

import '../../../data/config/di.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
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
          SplashBloc(repo: sl<SplashRepo>())..add(const SplashStarted()),
      child: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF7FBFC),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final circleSize = width * 0.82;
                  final logoWidth = circleSize * 0.64;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF9FBFC),
                              Color(0xFFF4FAFB),
                              Color(0xFFE7F6F8),
                            ],
                          ),
                        ),
                      ),
                      _GlowBlob(
                        alignment: const Alignment(-1.08, -0.96),
                        size: width * 0.34,
                        color: const Color(0xFFE9E0FF),
                      ),
                      _GlowBlob(
                        alignment: const Alignment(0.02, -0.92),
                        size: width * 0.42,
                        color: const Color(0xFFDDF8FB),
                      ),
                      _GlowBlob(
                        alignment: const Alignment(1.02, 0.34),
                        size: width * 0.32,
                        color: const Color(0xFFF7EAF4),
                      ),
                      _GlowBlob(
                        alignment: const Alignment(-0.86, 1.02),
                        size: width * 0.5,
                        color: const Color(0xFFCCF3F7),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.1),
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFFE9E1D6).withValues(alpha: 0.72),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            Images.appLogo,
                            width: logoWidth,
                            fit: BoxFit.contain,
                            color: Styles.PRIMARY_COLOR,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 650.ms, curve: Curves.easeOut)
                          .scale(
                            begin: const Offset(0.96, 0.96),
                            end: const Offset(1, 1),
                            duration: 900.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.35),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.85),
              blurRadius: size * 0.48,
              spreadRadius: size * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}
