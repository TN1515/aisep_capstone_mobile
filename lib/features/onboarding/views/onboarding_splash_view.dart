import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class OnboardingSplashView extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingSplashView({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), onComplete);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(seconds: 1),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              duration: const Duration(seconds: 1),
              delay: const Duration(milliseconds: 500),
              child: Text(
                'AISEP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeIn(
              duration: const Duration(seconds: 1),
              delay: const Duration(seconds: 1),
              child: Text(
                'HỆ SINH THÁI STARTUP',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: AppColors.text.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
