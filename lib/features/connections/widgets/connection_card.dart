import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/connection_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';

class ConnectionCard extends StatelessWidget {
  final ConnectionModel connection;
  final VoidCallback? onTap;
  final VoidCallback? onChat;

  const ConnectionCard({
    Key? key,
    required this.connection,
    this.onTap,
    this.onChat,
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
                // 1. Header (Status + Match Score)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(),
                    _buildMatchScore(),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Identity Section
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: accentColor.withOpacity(0.1),
                          backgroundImage: (connection.investorAvatarUrl != null && connection.investorAvatarUrl!.isNotEmpty)
                              ? NetworkImage(
                                  connection.investorAvatarUrl!.startsWith('http')
                                      ? connection.investorAvatarUrl!
                                      : '${AppConfig.apiBaseUrl}${connection.investorAvatarUrl!.startsWith('/') ? '' : '/'}${connection.investorAvatarUrl!}'
                                )
                              : null,
                          child: (connection.investorAvatarUrl == null || connection.investorAvatarUrl!.isEmpty)
                              ? Icon(
                                  connection.role == ConnectionRole.investor 
                                    ? LucideIcons.briefcase 
                                    : LucideIcons.graduationCap,
                                  color: accentColor,
                                )
                              : null,
                        ),
                        if (connection.isVerified)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
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
                          Text(
                            connection.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${connection.position}${connection.organization != null ? ' • ${connection.organization}' : ''}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Bio / Short Description
                if (connection.bio != null)
                  Text(
                    connection.bio!,
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: textColor.withOpacity(0.9),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),

                // 4. Tags Array
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: connection.tags.map((tag) => _buildTag(tag)).toList(),
                ),
                const SizedBox(height: 20),

                // 5. Actions
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentColor.withOpacity(0.5)),
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Hồ sơ',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: ElevatedButton(
                        onPressed: onChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: StartupOnboardingTheme.navyBg,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.messageCircle, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Nhắn tin',
                                style: GoogleFonts.workSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStatusBadge() {
    Color color = StartupOnboardingTheme.goldAccent;
    String label = 'Đang chờ';

    switch (connection.status) {
      case ConnectionStatus.active:
        color = const Color(0xFF10B981);
        label = 'Đã kết nối';
        break;
      case ConnectionStatus.rejected:
      case ConnectionStatus.cancelled:
        color = const Color(0xFFEF4444);
        label = 'Đã hủy';
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMatchScore() {
    final score = (connection.matchScore * 100).toInt();
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

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 11,
          color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
        ),
      ),
    );
  }
}
