import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/profile_setup_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StartupIndustrySelector extends StatelessWidget {
  final String label;
  final String? hint;
  final String selectedIndustry;
  final String selectedSubIndustry;
  final List<IndustryCategory> categories;
  final Function(String category, String sub) onSelected;
  final String? Function(String?)? validator;

  const StartupIndustrySelector({
    super.key,
    required this.label,
    required this.selectedIndustry,
    required this.selectedSubIndustry,
    required this.categories,
    required this.onSelected,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue = selectedSubIndustry.isNotEmpty 
        ? selectedSubIndustry
        : selectedIndustry;

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
                    displayValue.isEmpty ? (hint ?? 'Chọn lĩnh vực') : displayValue,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: displayValue.isEmpty 
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
            key: ValueKey(selectedSubIndustry),
            initialValue: selectedSubIndustry,
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
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
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
                    'Chọn lĩnh vực',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: StartupOnboardingTheme.navyBg,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              category.name,
                              style: GoogleFonts.workSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: StartupOnboardingTheme.navyBg,
                              ),
                            ),
                          ),
                          ...category.subIndustries.map((sub) {
                            bool isSelected = selectedIndustry == category.name && 
                                            selectedSubIndustry == sub;
                            return InkWell(
                              onTap: () {
                                onSelected(category.name, sub);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: isSelected 
                                          ? StartupOnboardingTheme.goldAccent
                                          : Colors.grey[200]!,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sub,
                                        style: GoogleFonts.workSans(
                                          fontSize: 16,
                                          color: isSelected 
                                              ? StartupOnboardingTheme.goldAccent
                                              : StartupOnboardingTheme.navyBg.withOpacity(0.7),
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
                          }).toList(),
                          const Divider(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
