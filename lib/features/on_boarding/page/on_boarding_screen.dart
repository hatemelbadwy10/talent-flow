import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/on_boarding/widget/on_boarding_button.dart';
import 'package:talent_flow/features/on_boarding/widget/page_content_widget.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/images.dart';
import '../bloc/on_boarding_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(Init()),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> onboardingData = [
      {
        "title": "onboarding.page1.title".tr(),
        "description": "onboarding.page1.description".tr(),
      },
      {
        "title": "onboarding.page2.title".tr(),
        "description": "onboarding.page2.description".tr(),
      },
      {
        "title": "onboarding.page3.title".tr(),
        "description": "onboarding.page3.description".tr(),
      },
    ];

    return BlocListener<OnboardingBloc, AppState>(
      listener: (context, state) {
        if (state is Done && state.data is int) {
          _pageController.animateToPage(
            state.data,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Background Image
            Image.asset(
              Images.onBoardingPhoto,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),

            // 2. Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0C7D81),
                    const Color(0xFF0C7D81).withOpacity(0.8),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.4, 0.5, 1.0],
                ),
              ),
            ),

            // 3. Page Content
            Column(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 1,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (int page) {
                      context
                          .read<OnboardingBloc>()
                          .add(Scroll(arguments: page));
                    },
                    itemBuilder: (context, index) {
                      return PageContentWidget(
                        // Get data from the new list
                        title: onboardingData[index]['title']!,
                        description: onboardingData[index]['description']!,
                      );
                    },
                  ),
                ),
                BlocBuilder<OnboardingBloc, AppState>(
                  builder: (context, state) {
                    final currentPage = (state is Done && state.data is int)
                        ? state.data as int
                        : 0;
                    return OnBoardingButton(
                      currentPage: currentPage,
                      onboardingData: onboardingData,
                    );
                  },
                ),
                const SizedBox(height: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }
}