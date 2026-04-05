import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
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
    String label = 'Yêu cầu';

    switch (status) {
      case ConnectionStatus.pending:
        color = StartupOnboardingTheme.goldAccent;
        label = 'Đã gửi';
        break;
      case ConnectionStatus.received:
        color = const Color(0xFF3B82F6); // Blue
        label = 'Đã nhận';
        break;
      case ConnectionStatus.active:
        color = const Color(0xFF10B981); // Emerald
        label = 'Đã kết nối';
        break;
      case ConnectionStatus.rejected:
        color = const Color(0xFFEF4444); // Red
        label = 'Từ chối';
        break;
      case ConnectionStatus.cancelled:
        color = StartupOnboardingTheme.slateGray;
        label = 'Đã hủy';
        break;
      case ConnectionStatus.expired:
        color = Colors.orange;
        label = 'Hết hạn';
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
}
