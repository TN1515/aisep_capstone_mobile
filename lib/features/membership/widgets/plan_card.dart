import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/membership_plan_model.dart';

class PlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final bool isSelected;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.isCurrentPlan,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool showPopular = plan.isPopular;
    final Color accentColor = plan.accentColor ?? StartupOnboardingTheme.goldAccent;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected 
              ? accentColor.withOpacity(0.12)
              : StartupOnboardingTheme.navySurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected 
                ? accentColor 
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Badge & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCurrentPlan)
                  _buildStatusBadge('GÓI HIỆN TẠI', Colors.green)
                else if (showPopular)
                  _buildStatusBadge('PHỔ BIẾN', StartupOnboardingTheme.goldAccent)
                else
                  const SizedBox(height: 22), // Alignment spacer
              ],
            ),
            const SizedBox(height: 20),
            
            // Tier Name
            Text(
              plan.name,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? accentColor : StartupOnboardingTheme.softIvory,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              plan.tagline,
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Pricing
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.price != '0' ? '${plan.price}đ' : 'Free',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.softIvory,
                  ),
                ),
                if (plan.price != '0') ...[
                  const SizedBox(width: 4),
                  Text(
                    '/${plan.period}',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: StartupOnboardingTheme.softIvory.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 24),
            
            // Benefits List (Selected top 3-4 highlights)
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: plan.features
                    .where((f) => f.isHighlight)
                    .take(4)
                    .map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: isSelected ? accentColor : Colors.white24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  feature.name,
                                  style: GoogleFonts.workSans(
                                    fontSize: 12.5,
                                    color: StartupOnboardingTheme.softIvory.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
