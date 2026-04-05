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
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Colors.white.withOpacity(0.02) 
              : StartupOnboardingTheme.goldAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead 
                ? Colors.white.withOpacity(0.05) 
                : StartupOnboardingTheme.goldAccent.withOpacity(0.2),
          ),
          boxShadow: notification.isRead ? [] : [
            BoxShadow(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryIcon(),
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
                                ? StartupOnboardingTheme.softIvory.withOpacity(0.9)
                                : StartupOnboardingTheme.softIvory,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: StartupOnboardingTheme.goldAccent,
                            shape: BoxShape.circle,
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
                      color: StartupOnboardingTheme.softIvory.withOpacity(notification.isRead ? 0.6 : 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: StartupOnboardingTheme.slateGray.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.document:
        icon = LucideIcons.fileText;
        color = Colors.blueAccent;
        break;
      case NotificationType.ai:
        icon = LucideIcons.zap;
        color = StartupOnboardingTheme.goldAccent;
        break;
      case NotificationType.connection:
        icon = LucideIcons.users;
        color = Colors.greenAccent;
        break;
      case NotificationType.kyc:
        icon = LucideIcons.shieldCheck;
        color = Colors.orangeAccent;
        break;
      default:
        icon = LucideIcons.info;
        color = StartupOnboardingTheme.softIvory;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(dt);
  }
}
