import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/on_boarding/widget/on_boarding_button.dart';
import 'package:talent_flow/features/on_boarding/widget/page_content_widget.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/images.dart';
import '../bloc/on_boarding_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "اشتغل على طريقك",
      "description":
      "سواء كنت مصمم، مطوّر، كاتب أو أي مجال ثاني – تلقى مشاريع تناسب مهاراتك وتشتغل عليها وأنت مرتاح.",
    },
    {
      "title": "كن أفضل المستقلين",
      "description":
      "احتاجت تصميم، تطوير، كتابة أو أي خدمة؟ بتلقى فريلانسر جاهزين ينفذون مشروعك بكل احترافية.",
    },
    {
      "title": "كل شيء في مكان واحد",
      "description":
      "من إرسال العروض، إدارة المشروع، للدفع الآمن – كل خطوات الشغل بينك وبين الطرف الثاني بشكل سلس وآمن.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<OnboardingBloc, AppState>(
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

              // 2. Corrected Gradient Overlay (Matches Figma)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0C7D81), // Solid teal at the bottom
                      const Color(0xFF0C7D81).withOpacity(0.8), // Fades to semi-transparent
                      Colors.white.withOpacity(0.0), // Fully transparent white at the top
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.4, 0.5, 1.0],
                  ),
                ),
              ),

              // 3. Your Page Content
              Column(
                children: [
                  const Expanded(flex: 2, child: SizedBox()),
                  Expanded(
                    flex: 1,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _onboardingData.length,
                      onPageChanged: (int page) {
                        context
                            .read<OnboardingBloc>()
                            .add(Scroll(arguments: page));
                      },
                      itemBuilder: (context, index) {
                        return PageContentWidget(
                          title: _onboardingData[index]['title']!,
                          description: _onboardingData[index]['description']!,
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
                        onboardingData: _onboardingData,
                      );
                    },
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}