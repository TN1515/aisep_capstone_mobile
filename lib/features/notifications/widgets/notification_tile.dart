import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Theme.of(context).cardColor 
              : StartupOnboardingTheme.goldAccent.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead 
                ? Theme.of(context).dividerColor.withOpacity(isDark ? 0.1 : 0.05) 
                : StartupOnboardingTheme.goldAccent.withOpacity(0.3),
          ),
          boxShadow: notification.isRead ? [] : [
            BoxShadow(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryIcon(context),
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
                          notification.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: notification.isRead 
                                ? Theme.of(context).textTheme.displayLarge?.color?.withOpacity(0.8)
                                : Theme.of(context).textTheme.displayLarge?.color,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: StartupOnboardingTheme.goldAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: StartupOnboardingTheme.goldAccent.withOpacity(0.5),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.content,
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(notification.isRead ? 0.6 : 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                      ),
                      if (notification.relatedEntityId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Chi tiết',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: StartupOnboardingTheme.goldAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.AI_EVALUATION:
        icon = LucideIcons.zap;
        color = StartupOnboardingTheme.goldAccent;
        break;
      case NotificationType.CONNECTION_REQUEST:
        icon = LucideIcons.userPlus;
        color = Colors.blueAccent;
        break;
      case NotificationType.CONNECTION_ACCEPTED:
        icon = LucideIcons.checkCircle;
        color = Colors.greenAccent;
        break;
      case NotificationType.MESSAGE:
        icon = LucideIcons.mail;
        color = Colors.indigoAccent;
        break;
      case NotificationType.KYC_STATUS:
        icon = LucideIcons.shieldCheck;
        color = Colors.orangeAccent;
        break;
      case NotificationType.MENTORSHIP:
        icon = LucideIcons.coffee;
        color = Colors.purpleAccent;
        break;
      default:
        icon = LucideIcons.bell;
        color = StartupOnboardingTheme.goldAccent;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(dt);
  }
}
