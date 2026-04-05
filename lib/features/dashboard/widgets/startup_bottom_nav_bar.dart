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
      color: Theme.of(context).cardColor, // Use theme card color
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
                  _buildNavItem(context, LucideIcons.users, 'Kết nối', 0),
                  _buildNavItem(context, LucideIcons.graduationCap, 'Tư vấn', 1),
                ],
              ),
            ),
            
            const SizedBox(width: 60), // Larger gap for center FAB
            
            // Last two items (Right)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, LucideIcons.fileText, 'Tài liệu', 3),
                  _buildNavItem(context, LucideIcons.shieldCheck, 'Xác thực', 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;
    final theme = Theme.of(context);
    final Color color = isActive ? theme.primaryColor : theme.textTheme.bodyLarge?.color?.withOpacity(0.4) ?? Colors.grey;

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
