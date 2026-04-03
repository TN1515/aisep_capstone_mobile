import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_card.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/onboarding_stepper.dart';

class OnboardingCarouselView extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const OnboardingCarouselView({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<OnboardingCarouselView> createState() => _OnboardingCarouselViewState();
}

class _OnboardingCarouselViewState extends State<OnboardingCarouselView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Build your Startup\nProfile with clarity',
      'description': 'Create a professional presence that attracts the right biotech partners and investors.',
      'icon': LucideIcons.layout,
      'color': AppColors.card,
    },
    {
      'title': 'Organize key startup\nmaterials in one place',
      'description': 'Keep your pitch deck, scientific data, and business plan structured and ready.',
      'icon': LucideIcons.folderKey,
      'color': AppColors.card,
    },
    {
      'title': 'Prepare for AI-powered\nstartup evaluation',
      'description': 'Leverage our intelligent ecosystem to identify strengths and market-readiness.',
      'icon': LucideIcons.brainCircuit,
      'color': AppColors.card,
    },
    {
      'title': 'Move forward with\nconfidence and\nexpert guidance',
      'description': 'Scale your biotechnology venture with a clear roadmap and expert insights.',
      'icon': LucideIcons.compass,
      'color': AppColors.card,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnboardingStepper(
                    totalSteps: _slides.length,
                    currentStep: _currentIndex,
                  ),
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppColors.spaceXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: StartupCard(
                            borderRadius: 48,
                            padding: const EdgeInsets.all(48),
                            color: slide['color'],
                            child: Icon(
                              slide['icon'],
                              size: 80,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 64),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            slide['title'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            slide['description'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.text.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppColors.spaceXL),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onComplete();
                    }
                  },
                  child: Text(_currentIndex == _slides.length - 1 ? 'Continue' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
