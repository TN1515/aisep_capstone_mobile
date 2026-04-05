import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class AdvisorCard extends StatelessWidget {
  final AdvisorModel advisor;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const AdvisorCard({
    Key? key,
    required this.advisor,
    this.onTap,
    this.onBookmark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(advisor.avatarUrl),
                        ),
                        if (advisor.status == AdvisorStatus.active)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: StartupOnboardingTheme.navySurface, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  advisor.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: StartupOnboardingTheme.softIvory,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: onBookmark,
                                child: Icon(
                                  advisor.isBookmarked ? Icons.favorite : LucideIcons.heart,
                                  color: advisor.isBookmarked ? Colors.redAccent : Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            advisor.title,
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: StartupOnboardingTheme.goldAccent.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: advisor.expertise.take(3).map((e) => _buildExpertiseChip(e)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(LucideIcons.star, advisor.rating.toString(), 'Rating', color: Colors.orangeAccent),
                    _buildStatItem(LucideIcons.calendar, advisor.totalSessions.toString(), 'Sessions'),
                    _buildStatItem(LucideIcons.briefcase, '${advisor.yearsExperience}y', 'Exp'),
                    Text(
                      currencyFormat.format(advisor.hourlyRate),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: StartupOnboardingTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertiseChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.softIvory,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: StartupOnboardingTheme.softIvory.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
