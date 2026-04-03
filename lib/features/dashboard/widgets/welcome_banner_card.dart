import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class WelcomeBannerCard extends StatelessWidget {
  const WelcomeBannerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.softIvory,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.navyBg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s schedule your\nproject.',
                  style: GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: StartupOnboardingTheme.navyBg.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Container(
              width: 160,
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/images/illustrations/startup_welcome_illustration.png', 
                // Note: I will need to remind the user to add this asset, 
                // or I can try to use a placeholder if I can't confirm asset paths.
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.rocket_launch_outlined,
                  size: 80,
                  color: StartupOnboardingTheme.goldAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
