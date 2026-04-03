import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class ChipSelector extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        bool isSelected = option == selectedOption;
        return InkWell(
          onTap: () => onSelected(option),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: Text(
              option,
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.softIvory.withOpacity(0.8),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
