import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import '../../../app/core/images.dart';

class AuthBase extends StatelessWidget {
  final List<Widget> children;

  const AuthBase({
    super.key,
    required this.children,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0C7D81),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6],
              ),
            ),
          ),

          // Background Circles
          Positioned(
            left: -screenWidth * 0.6,
            child: Image.asset(
              Images.halfCircle,
              width: screenWidth * 0.9,
            ),
          ),
          Positioned(
            right: -screenWidth * 0.2,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                Images.circle,
                height: screenHeight * 0.25,
                width: screenWidth * 1.5,
              ),
            ),
          ),

          // Safe Scrollable Content
          SafeArea(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 20.w,
              ),
              child: ListAnimator(
                data: [
                  SizedBox(height: screenHeight * .125),
                  // Logo
                  Center(
                    child: Image.asset(
                      Images.appLogo,
                      width: 109.33,
                      height: 94,
                    ),
                  ),

                  ...children,
                ],
                durationMilli: 300,
                verticalOffset: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
