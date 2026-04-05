import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/models/dashboard_stats_model.dart';

class ActivityItemTile extends StatelessWidget {
  final RecentActivity activity;

  const ActivityItemTile({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTypeColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(),
              color: _getTypeColor(context),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (activity.type) {
      case 'document': return Icons.article_rounded;
      case 'connection': return Icons.people_rounded;
      case 'ai': return Icons.auto_awesome_rounded;
      case 'kyc': return Icons.verified_user_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(BuildContext context) {
    switch (activity.type) {
      case 'document': return Colors.blueAccent;
      case 'connection': return Colors.greenAccent;
      case 'ai': return Theme.of(context).primaryColor;
      case 'kyc': return Colors.orangeAccent;
      default: return Theme.of(context).primaryColor;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    
    // Manual formatting: dd/MM/yyyy
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }
}
