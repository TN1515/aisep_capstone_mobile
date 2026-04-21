import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StartupDropdownField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const StartupDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.hint,
    this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.navyBg.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
        DropdownButtonFormField<String>(
          value: value?.isEmpty == true ? null : value,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          icon: const Icon(LucideIcons.chevronDown, color: StartupOnboardingTheme.goldAccent, size: 20),
          style: GoogleFonts.workSans(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.workSans(
              fontSize: 14,
              color: StartupOnboardingTheme.slateGray.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: StartupOnboardingTheme.goldAccent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
