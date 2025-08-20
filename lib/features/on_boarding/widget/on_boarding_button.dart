import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/app_event.dart';
import '../../../navigation/routes.dart';
import '../bloc/on_boarding_bloc.dart';
import 'build_dot_widget.dart';
class OnBoardingButton extends StatelessWidget {
  const OnBoardingButton({super.key, required this.onboardingData, required this.currentPage});
  final List<Map<String, String>> onboardingData;
  final int currentPage;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => BuildDotWidget(index:  index,currentPage:  currentPage),
            ),
          ),
          SizedBox(height: 50.h),
          ElevatedButton(
            onPressed: () {
              if (currentPage < onboardingData.length - 1) {
                context.read<OnboardingBloc>().add(Click());
              } else {
                CustomNavigator.push(Routes.freeLancer, clean: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffCEE5E6),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              currentPage < onboardingData.length - 1 ? 'التالي' : 'ابدأ الآن',
              style: const TextStyle(
                  color: Color(0xFF0C7D81),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

}
