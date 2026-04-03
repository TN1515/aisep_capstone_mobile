import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class StatMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: StartupOnboardingTheme.softIvory.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: StartupOnboardingTheme.goldAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.softIvory,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    color: StartupOnboardingTheme.slateGray.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
