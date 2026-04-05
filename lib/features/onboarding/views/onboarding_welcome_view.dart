import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_card.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class OnboardingWelcomeView extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingWelcomeView({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppColors.spaceXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: const Duration(seconds: 1),
                          child: StartupCard(
                            borderRadius: 40,
                            padding: const EdgeInsets.all(40),
                            color: Theme.of(context).cardColor,
                            child: const Icon(
                              Icons.rocket_launch,
                              size: 80,
                              color: StartupOnboardingTheme.goldAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        FadeInUp(
                          duration: const Duration(seconds: 1),
                          child: Text(
                            'Tiếp sức cho thế hệ\nStartup Công nghệ sinh học\ntiếp theo',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(seconds: 1),
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            'Nền tảng hỗ trợ AI để xây dựng, quản lý và\nmở rộng quy mô liên doanh công nghệ sinh học.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FadeInUp(
                duration: const Duration(seconds: 1),
                delay: const Duration(seconds: 1),
                child: Padding(
                  padding: const EdgeInsets.all(AppColors.spaceXL),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onNext,
                          child: const Text('Bắt đầu'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AISEP for Startups',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
