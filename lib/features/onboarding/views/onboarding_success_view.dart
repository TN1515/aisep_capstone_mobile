import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_card.dart';

class OnboardingSuccessView extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingSuccessView({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppColors.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(seconds: 1),
                child: StartupCard(
                  borderRadius: 100,
                  padding: const EdgeInsets.all(40),
                  color: AppColors.primary,
                  child: const Icon(
                    LucideIcons.checkCircle2,
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'Great job!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 800),
                child: Text(
                  'Your startup space is ready. Now let’s\ntransform your vision into impact.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.text.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 64),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    _buildActionCard(
                      LucideIcons.userCheck,
                      'Complete Startup Profile',
                      'Attract investors and biotech partners.',
                      onComplete,
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      LucideIcons.fileSearch,
                      'Prepare AI Evaluation',
                      'Get professional ecosystem insights.',
                      () {},
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 1400),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    child: const Text('Go to Dashboard'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: StartupCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.text.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.text.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
