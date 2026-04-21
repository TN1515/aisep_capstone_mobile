import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/models/dashboard_stats_model.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class SummaryProgressCard extends StatelessWidget {
  final double profileCompletion;
  final DashboardKycStatus kycStatus;
  final int? aiScore;
  final bool isAiEvaluating;
  final VoidCallback? onKycTap;
  final VoidCallback? onAiTap;

  const SummaryProgressCard({
    Key? key,
    required this.profileCompletion,
    required this.kycStatus,
    this.aiScore,
    this.isAiEvaluating = false,
    this.onKycTap,
    this.onAiTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onKycTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  _buildCircularProgress(context),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoàn thiện hồ sơ',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hãy hoàn thiện 100% để tăng cơ hội kết nối với nhà đầu tư.',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: theme.dividerColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  context,
                  'Xác thực KYC',
                  _getKycText(),
                  _getKycColor(),
                  onTap: onKycTap,
                ),
                _buildStatusItem(
                  context,
                  'Đánh giá AI',
                  isAiEvaluating ? 'Đang xử lý...' : (aiScore != null ? '$aiScore/100' : 'Chưa có'),
                  isAiEvaluating ? Colors.orange : theme.primaryColor,
                  onTap: onAiTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: profileCompletion,
            backgroundColor: theme.dividerColor,
            color: theme.primaryColor,
            strokeWidth: 6,
          ),
        ),
        Text(
          '${(profileCompletion * 100).toInt()}%',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value, Color color, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Text(
              value,
              style: GoogleFonts.workSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getKycText() {
    switch (kycStatus) {
      case DashboardKycStatus.none: return 'Cần gửi hồ sơ';
      case DashboardKycStatus.pending: return 'Chờ duyệt';
      case DashboardKycStatus.verified: return 'Đã xác thực';
      case DashboardKycStatus.rejected: return 'Cần cập nhật';
    }
  }

  Color _getKycColor() {
    switch (kycStatus) {
      case DashboardKycStatus.none: return Colors.blueGrey;
      case DashboardKycStatus.pending: return Colors.orange;
      case DashboardKycStatus.verified: return Colors.green;
      case DashboardKycStatus.rejected: return Colors.red;
    }
  }
}
