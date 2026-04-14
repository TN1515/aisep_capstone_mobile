import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/connection_model.dart';

class ConnectionStatusBadge extends StatelessWidget {
  final ConnectionStatus status;

  const ConnectionStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = StartupOnboardingTheme.goldAccent;
    String label = 'Đang chờ';
    IconData icon = LucideIcons.clock;

    switch (status) {
      case ConnectionStatus.requested:
      case ConnectionStatus.pending:
      case ConnectionStatus.received:
        color = const Color(0xFF3B82F6); // Blue
        label = 'Đang chờ';
        icon = LucideIcons.clock;
        break;
      case ConnectionStatus.accepted:
      case ConnectionStatus.active:
        color = const Color(0xFF10B981); // Emerald
        label = 'Đã kết nối';
        icon = LucideIcons.checkCircle2;
        break;
      case ConnectionStatus.withdrawn:
      case ConnectionStatus.cancelled:
        color = StartupOnboardingTheme.slateGray;
        label = 'Đã rút';
        icon = LucideIcons.undo2;
        break;
      case ConnectionStatus.closed:
      case ConnectionStatus.expired:
        color = StartupOnboardingTheme.slateGray;
        label = 'Đã đóng';
        icon = LucideIcons.lock;
        break;
      case ConnectionStatus.rejected:
        color = const Color(0xFFEF4444); // Red
        label = 'Bị từ chối';
        icon = LucideIcons.xCircle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.workSans(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
