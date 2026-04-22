import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/config/app_config.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String startupName;
  final int unreadCount;
  final String? avatarUrl;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.startupName,
    required this.unreadCount,
    this.avatarUrl,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.primaryColor;
    
    // Resolve full image URL
    final String? fullAvatarUrl = avatarUrl != null && avatarUrl!.isNotEmpty 
        ? (avatarUrl!.startsWith('http') ? avatarUrl : '${AppConfig.apiBaseUrl}/$avatarUrl'.replaceAll('//', '/').replaceFirst('http:/', 'http://').replaceFirst('https:/', 'https://'))
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: accentColor.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  startupName,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.displayLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Hero(
              tag: 'dashboard_avatar',
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.1),
                  backgroundImage: fullAvatarUrl != null ? NetworkImage(fullAvatarUrl) : null,
                  child: fullAvatarUrl == null 
                      ? Icon(LucideIcons.user, color: accentColor, size: 20)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
