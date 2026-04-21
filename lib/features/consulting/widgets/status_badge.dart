import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';

class StatusBadge extends StatelessWidget {
  final ConsultingStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case ConsultingStatus.requested:
        color = Colors.blueAccent;
        text = 'Chờ phản hồi';
        break;
      case ConsultingStatus.proposed:
        color = Colors.orangeAccent;
        text = 'Chờ xác nhận';
        break;
      case ConsultingStatus.confirmed:
        color = Theme.of(context).primaryColor;
        text = 'Đã xác nhận';
        break;
      case ConsultingStatus.payable:
        color = Colors.purpleAccent;
        text = 'Chờ thanh toán';
        break;
      case ConsultingStatus.paid:
        color = Colors.tealAccent;
        text = 'Đã thanh toán';
        break;
      case ConsultingStatus.conducted:
        color = Colors.indigoAccent;
        text = 'Đã diễn ra';
        break;
      case ConsultingStatus.completed:
        color = Colors.greenAccent;
        text = 'Hoàn tất';
        break;
      case ConsultingStatus.cancelled:
        color = Colors.redAccent;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.workSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
