import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String startupName;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.startupName,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: StartupOnboardingTheme.goldAccent.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  startupName,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.softIvory,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: StartupOnboardingTheme.softIvory,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
                gradient: const LinearGradient(
                  colors: [StartupOnboardingTheme.navySurface, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.person_rounded, color: StartupOnboardingTheme.goldAccent, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
