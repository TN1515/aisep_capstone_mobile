import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class ActionTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback onAction;

  const ActionTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: StartupOnboardingTheme.softIvory.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: StartupOnboardingTheme.goldAccent,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.workSans(
                fontSize: 11,
                color: StartupOnboardingTheme.slateGray.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.15),
                foregroundColor: StartupOnboardingTheme.goldAccent,
                side: const BorderSide(color: StartupOnboardingTheme.goldAccent, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionText,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
