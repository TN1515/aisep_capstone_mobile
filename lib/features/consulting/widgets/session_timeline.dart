import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SessionTimeline extends StatelessWidget {
  final ConsultingStatus currentStatus;

  const SessionTimeline({Key? key, required this.currentStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stages = [
      {'label': 'Yêu cầu', 'icon': LucideIcons.filePlus, 'status': ConsultingStatus.requested},
      {'label': 'Xác nhận', 'icon': LucideIcons.calendarCheck, 'status': ConsultingStatus.confirmed},
      {'label': 'Thanh toán', 'icon': LucideIcons.creditCard, 'status': ConsultingStatus.paid},
      {'label': 'Hoàn tất', 'icon': LucideIcons.checkCircle, 'status': ConsultingStatus.completed},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: List.generate(stages.length * 2 - 1, (index) {
          // Even indices are nodes, odd indices are lines
          if (index.isEven) {
            final stageIndex = index ~/ 2;
            final stage = stages[stageIndex];
            final targetStatus = stage['status'] as ConsultingStatus;
            final bool isPast = _isPastOrCurrent(currentStatus, targetStatus);
            final bool isCurrent = currentStatus == targetStatus;

            return _buildNode(
              stage['label'] as String,
              stage['icon'] as IconData,
              isPast,
              isCurrent,
            );
          } else {
            // Line between nodes
            final nextStageIndex = (index + 1) ~/ 2;
            final nextStatus = stages[nextStageIndex]['status'] as ConsultingStatus;
            final bool isLineActive = _isPastOrCurrent(currentStatus, nextStatus);

            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isLineActive
                      ? StartupOnboardingTheme.goldAccent
                      : StartupOnboardingTheme.softIvory.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildNode(String label, IconData icon, bool isPast, bool isCurrent) {
    return SizedBox(
      width: 60, // Fixed width for nodes to ensure labels don't shift layout
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPast ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? Colors.white : Colors.white.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isPast ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.softIvory.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isPast ? StartupOnboardingTheme.softIvory : StartupOnboardingTheme.softIvory.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPastOrCurrent(ConsultingStatus current, ConsultingStatus target) {
    const order = [
      ConsultingStatus.requested,
      ConsultingStatus.proposed,
      ConsultingStatus.confirmed,
      ConsultingStatus.payable,
      ConsultingStatus.paid,
      ConsultingStatus.conducted,
      ConsultingStatus.completed,
    ];
    return order.indexOf(current) >= order.indexOf(target);
  }
}
