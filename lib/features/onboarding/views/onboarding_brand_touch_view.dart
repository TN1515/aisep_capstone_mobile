import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_card.dart';

class OnboardingBrandTouchView extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingBrandTouchView({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppColors.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'Give your Startup\na face',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Upload your logo or brand avatar.',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: AppColors.text.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FadeIn(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 300),
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement Image Picker
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: StartupCard(
                        borderRadius: 100,
                        padding: const EdgeInsets.all(50),
                        color: AppColors.card.withOpacity(0.3),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.imagePlus,
                              size: 64,
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to upload',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onNext,
                        child: const Text('Save and Continue'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: onNext,
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.dmSans(
                            color: AppColors.text.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
