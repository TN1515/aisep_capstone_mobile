import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
              color: AppColors.text,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: Theme.of(context).textTheme.bodyMedium),
                );
              }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.text),
        ),
        const SizedBox(height: AppColors.spaceMD),
      ],
    );
  }
}
