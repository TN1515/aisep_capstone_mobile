import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InvestorProfileHeader extends StatelessWidget {
  final InvestorModel investor;

  const InvestorProfileHeader({
    Key? key,
    required this.investor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = StartupOnboardingTheme.goldAccent;
    final Color textColor = StartupOnboardingTheme.softIvory;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: accentColor.withOpacity(0.1),
                  child: Icon(LucideIcons.user, color: accentColor, size: 40),
                ),
              ),
              if (investor.isVerified)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            investor.name,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${investor.position}${investor.organization != null ? ' @ ${investor.organization}' : ''}',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetric(LucideIcons.sparkles, '${(investor.matchScore * 100).toInt()}%', 'Phù hợp'),
              const SizedBox(width: 40),
              _buildMetric(LucideIcons.globe, investor.marketScope, 'Phạm vi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: StartupOnboardingTheme.goldAccent),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.softIvory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 10,
            color: StartupOnboardingTheme.softIvory.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
