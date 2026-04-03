import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

import 'package:lucide_icons/lucide_icons.dart';

class StartupBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StartupBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF0F172A), // Premium Dark Black-Navy for the nav bar
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 25,
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 64, // Compact height
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First two items (Left)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.people_alt_outlined, 'Kết nối', 0),
                  _buildNavItem(Icons.verified_user_outlined, 'Xác thực', 1),
                ],
              ),
            ),
            
            const SizedBox(width: 60), // Larger gap for center FAB
            
            // Last two items (Right)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.description_outlined, 'Tài liệu', 3),
                  _buildNavItem(Icons.person_outline, 'Hồ sơ', 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;
    final Color color = isActive ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.slateGray.withOpacity(0.8);
    final double iconWeight = isActive ? 0.8 : 0.4;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Reduced vertical padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24, // Compact icon size
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 10, // Slightly smaller font
                height: 1.2,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
