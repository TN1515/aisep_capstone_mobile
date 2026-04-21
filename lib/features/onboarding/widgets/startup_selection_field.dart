import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StartupSelectionField extends StatelessWidget {
  final String label;
  final String? hint;
  final String selectedValue;
  final List<String> options;
  final Function(String) onSelected;
  final String? Function(String?)? validator;
  final String? title;

  const StartupSelectionField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
    this.hint,
    this.validator,
    this.title,
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
        InkWell(
          onTap: () => _showSelectionSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue.isEmpty ? (hint ?? 'Chọn một tùy chọn') : selectedValue,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: selectedValue.isEmpty 
                          ? StartupOnboardingTheme.slateGray.withOpacity(0.5)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  LucideIcons.chevronDown,
                  color: StartupOnboardingTheme.goldAccent,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (validator != null)
          FormField<String>(
            key: ValueKey(selectedValue),
            initialValue: selectedValue,
            validator: validator,
            builder: (state) {
              if (state.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    state.errorText ?? '',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  void _showSelectionSheet(BuildContext context) async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  title ?? label,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.navyBg,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final item = options[index];
                    bool isSelected = selectedValue == item;
                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isSelected 
                                  ? StartupOnboardingTheme.goldAccent
                                  : Colors.grey[100]!,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.workSans(
                                  fontSize: 16,
                                  color: isSelected 
                                      ? StartupOnboardingTheme.goldAccent
                                      : StartupOnboardingTheme.navyBg.withOpacity(0.8),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: StartupOnboardingTheme.goldAccent,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
