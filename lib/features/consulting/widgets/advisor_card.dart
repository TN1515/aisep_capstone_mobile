import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:aisep_capstone_mobile/core/utils/ui_utils.dart';
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
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        // Border removed for ultra-clean look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.03), // Subtle shadow
            blurRadius: 25,
            offset: const Offset(0, 10),
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
                    _buildAvatarLayout(context),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            advisor.fullName,
                                            style: GoogleFonts.outfit(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                              color: theme.textTheme.displayLarge?.color,
                                            ),
                                          ),
                                        ),
                                        if (advisor.isVerified) ...[
                                          const SizedBox(width: 6),
                                          Icon(Icons.verified, size: 16, color: Colors.blue.shade600),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      advisor.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.workSans(
                                        fontSize: 12,
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildBookmarkButton(context),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: advisor.expertise.take(3).map((e) => _buildExpertiseChip(context, UIUtils.formatExpertiseLabel(e))).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatItem(context, LucideIcons.star, advisor.averageRating.toStringAsFixed(1), '(${advisor.reviewCount})', color: Colors.amber),
                    const SizedBox(width: 16),
                    _buildStatItem(context, LucideIcons.users, advisor.completedSessions.toString(), 'Học viên'),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(advisor.hourlyRate),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '/ giờ',
                          style: GoogleFonts.workSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                          ),
                        ),
                      ],
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

  Widget _buildAvatarLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.2),
            Theme.of(context).primaryColor.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          final String? url = UIUtils.getFullImageUrl(advisor.profilePhotoURL);
          if (url != null) {
            UIUtils.showImagePreview(context, imageUrl: url, tag: 'advisor_avatar_${advisor.id}');
          }
        },
        child: Hero(
          tag: 'advisor_avatar_${advisor.id}',
          child: CircleAvatar(
            radius: 34,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (advisor.profilePhotoURL.isNotEmpty)
                ? NetworkImage(UIUtils.getFullImageUrl(advisor.profilePhotoURL)!)
                : null,
            child: (advisor.profilePhotoURL.isEmpty)
                ? Icon(LucideIcons.user, color: Theme.of(context).primaryColor, size: 30)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onBookmark,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: advisor.isBookmarked ? Colors.red.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            advisor.isBookmarked ? Icons.favorite : LucideIcons.heart,
            color: advisor.isBookmarked ? Colors.redAccent : Colors.grey.withOpacity(0.4),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildExpertiseChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, {Color? color}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (color ?? theme.primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color ?? theme.primaryColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
