import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import '../view_models/connection_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InvestorDiscoveryCard extends StatelessWidget {
  final InvestorModel investor;
  final VoidCallback onTap;

  const InvestorDiscoveryCard({
    Key? key,
    required this.investor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = StartupOnboardingTheme.goldAccent;
    final Color surfaceColor = StartupOnboardingTheme.navySurface;
    final Color textColor = StartupOnboardingTheme.softIvory;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: accentColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMatchScore(),
                    const SizedBox(width: 12),
                    if (investor.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Color(0xFF10B981), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Đã xác thực',
                              style: GoogleFonts.workSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ConnectionViewModel().toggleFavorite(investor.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: investor.isFavorite ? accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          investor.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: investor.isFavorite ? const Color(0xFFEF4444) : accentColor.withOpacity(0.4),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: accentColor.withOpacity(0.1),
                      child: Icon(LucideIcons.briefcase, color: accentColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${investor.position}${investor.organization != null ? ' @ ${investor.organization}' : ''}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  investor.thesis,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: textColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...investor.preferredIndustries.take(2).map((tag) => _buildTag(tag, LucideIcons.tag)),
                    ...investor.preferredStages.take(1).map((tag) => _buildTag(tag, LucideIcons.trendingUp)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchScore() {
    final score = (investor.matchScore * 100).toInt();
    return Row(
      children: [
        Icon(LucideIcons.sparkles, color: StartupOnboardingTheme.goldAccent, size: 14),
        const SizedBox(width: 4),
        Text(
          '$score% Phù hợp',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: StartupOnboardingTheme.slateGray),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
