import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/styles.dart';
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
              backgroundColor:Styles.PRIMARY_COLOR,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              currentPage < onboardingData.length - 1 ? 'next'.tr() : 'start'.tr(),
              style: const TextStyle(
                  color: Styles.WHITE_COLOR,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,

              ),
            ),
          ),
        ],
      ),
    );
  }

}
