import 'package:flutter/material.dart';
import '../../../../core/theme/startup_onboarding_theme.dart';

class ProfileDropdownField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: StartupOnboardingTheme.navySurface,
          items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item, 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: StartupOnboardingTheme.softIvory,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: StartupOnboardingTheme.softIvory.withOpacity(0.3),
            ),
            filled: true,
            fillColor: StartupOnboardingTheme.navyBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StartupOnboardingTheme.goldAccent, width: 1.5),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: StartupOnboardingTheme.goldAccent),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
