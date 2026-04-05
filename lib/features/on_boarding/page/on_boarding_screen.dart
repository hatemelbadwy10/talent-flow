import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/features/on_boarding/widget/on_boarding_button.dart';
import 'package:talent_flow/features/on_boarding/widget/page_content_widget.dart';

import '../../../app/core/images.dart';
import '../bloc/on_boarding_bloc.dart';
import '../bloc/on_boarding_event.dart';
import '../bloc/on_boarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(const OnboardingStarted()),
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
        'image': Images.onBoardingPhoto,
        'title': 'onboarding.page1.title'.tr(),
        'description': 'onboarding.page1.description'.tr(),
      },
      {
        'image': Images.onBoardingPhoto2,
        'title': 'onboarding.page2.title'.tr(),
        'description': 'onboarding.page2.description'.tr(),
      },
      {
        'image': Images.onBoardingPhoto3,
        'title': 'onboarding.page3.title'.tr(),
        'description': 'onboarding.page3.description'.tr(),
      },
    ];

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        _pageController.animateToPage(
          state.currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (int page) {
                    context
                        .read<OnboardingBloc>()
                        .add(OnboardingPageChanged(page));
                  },
                  itemBuilder: (context, index) {
                    return PageContentWidget(
                      imagePath: onboardingData[index]['image']!,
                      title: onboardingData[index]['title']!,
                      description: onboardingData[index]['description']!,
                    );
                  },
                ).paddingAll(16),
              ),
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  return OnBoardingButton(
                    currentPage: state.currentPage,
                    onboardingData: onboardingData,
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
