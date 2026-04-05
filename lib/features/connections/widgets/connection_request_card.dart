import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/connection_model.dart';
import 'connection_status_badge.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class ConnectionRequestCard extends StatelessWidget {
  final ConnectionModel connection;
  final VoidCallback onTap;

  const ConnectionRequestCard({
    Key? key,
    required this.connection,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConnectionStatusBadge(status: connection.status),
                    Text(
                      DateFormat('dd/MM/yyyy').format(connection.lastUpdated),
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: textColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: accentColor.withOpacity(0.1),
                      child: Icon(LucideIcons.user, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            connection.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${connection.position}${connection.organization != null ? ' @ ${connection.organization}' : ''}',
                            style: GoogleFonts.workSans(
                              fontSize: 11,
                              color: textColor.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: textColor.withOpacity(0.2), size: 18),
                  ],
                ),
                if (connection.bio != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    connection.bio!,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
