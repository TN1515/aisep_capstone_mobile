import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/membership_plan_model.dart';

class FeatureComparisonTable extends StatelessWidget {
  final List<MembershipPlan> plans;
  final MembershipTier selectedTier;

  const FeatureComparisonTable({
    super.key,
    required this.plans,
    required this.selectedTier,
  });

  @override
  Widget build(BuildContext context) {
    // Get features for the currently selected plan
    final selectedPlan = plans.firstWhere((p) => p.tier == selectedTier);
    final accentColor = selectedPlan.accentColor ?? StartupOnboardingTheme.goldAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHI TIẾT QUYỀN LỢI',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                selectedPlan.name,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedPlan.features.length,
          itemBuilder: (context, index) {
            final feature = selectedPlan.features[index];
            return _buildFeatureItem(context, feature, accentColor);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, MembershipFeature feature, Color accentColor) {
    final bool isAvailable = _isFeatureAvailable(feature.value);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: feature.isHighlight 
              ? accentColor.withOpacity(0.2) 
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? accentColor.withOpacity(0.12) 
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.check_rounded : Icons.close_rounded,
              size: 14,
              color: isAvailable ? accentColor : Colors.white24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              feature.name,
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: feature.isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isAvailable 
                    ? Theme.of(context).textTheme.displayLarge?.color 
                    : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
              ),
            ),
          ),
          if (feature.value is String)
            Text(
              feature.value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isAvailable ? accentColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.2),
              ),
            ),
        ],
      ),
    );
  }

  bool _isFeatureAvailable(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() != 'x' && value.isNotEmpty;
    return true;
  }
}
