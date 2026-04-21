import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/connection_model.dart';
import 'connection_status_badge.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';

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
    final theme = Theme.of(context);
    final statusColor = connection.status.color;
    final Color surfaceColor = theme.cardColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: connection.status == ConnectionStatus.accepted ? 2 : 1,
        ),
        boxShadow: connection.status == ConnectionStatus.accepted ? [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Status-based background tint
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor.withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Material(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConnectionStatusBadge(status: connection.status),
                          Row(
                            children: [
                              if (connection.status == ConnectionStatus.accepted)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(LucideIcons.messageSquare, size: 14, color: statusColor),
                                ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(connection.lastUpdated),
                                style: GoogleFonts.workSans(
                                  fontSize: 11,
                                  color: textColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: statusColor.withOpacity(0.1),
                              backgroundImage: (connection.investorAvatarUrl != null && connection.investorAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(
                                      connection.investorAvatarUrl!.startsWith('http')
                                          ? connection.investorAvatarUrl!
                                          : '${AppConfig.apiBaseUrl}${connection.investorAvatarUrl!.startsWith('/') ? '' : '/'}${connection.investorAvatarUrl!}'
                                    )
                                  : null,
                              child: (connection.investorAvatarUrl == null || connection.investorAvatarUrl!.isEmpty)
                                  ? Icon(LucideIcons.user, color: statusColor, size: 20)
                                  : null,
                            ),
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
                                  '${connection.position}${connection.organization != null ? ' • ${connection.organization}' : ''}',
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
                            color: textColor.withOpacity(0.6),
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
          ],
        ),
      ),
    );
  }
}
