import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/onboarding_content_widget.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/onboarding_nav_buttons.dart';
import 'package:aisep_capstone_mobile/features/onboarding/view_models/onboarding_view_model.dart';

class StartupOnboardingScreen extends StatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  State<StartupOnboardingScreen> createState() => _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends State<StartupOnboardingScreen> {
  late final OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                // Page Indicator at top
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SmoothPageIndicator(
                    controller: _viewModel.pageController,
                    count: _viewModel.pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: StartupOnboardingTheme.goldAccent,
                      dotColor: Theme.of(context).dividerColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                ),
                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _viewModel.pageController,
                    onPageChanged: _viewModel.onPageChanged,
                    itemCount: _viewModel.pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingContentWidget(model: _viewModel.pages[index]);
                    },
                  ),
                ),
                // Navigation Buttons
                OnboardingNavButtons(
                  isLastPage: _viewModel.currentPage == _viewModel.pages.length - 1,
                  onNext: () => _viewModel.next(context),
                  onSkip: _viewModel.skip,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
