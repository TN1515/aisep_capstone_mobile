import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/models/dashboard_stats_model.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';

class SummaryProgressCard extends StatelessWidget {
  final double profileCompletion;
  final DashboardKycStatus kycStatus;
  final int? aiScore;
  final VoidCallback? onKycTap;

  const SummaryProgressCard({
    Key? key,
    required this.profileCompletion,
    required this.kycStatus,
    this.aiScore,
    this.onKycTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: StartupOnboardingTheme.navySurface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AppColors.text.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildCircularProgress(),
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
                          color: StartupOnboardingTheme.softIvory,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hãy hoàn thiện 100% để tăng cơ hội kết nối với nhà đầu tư.',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: StartupOnboardingTheme.slateGray.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.white10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  'Xác thực KYC',
                  _getKycText(),
                  _getKycColor(),
                  onTap: onKycTap,
                ),
                _buildStatusItem(
                  'Đánh giá AI',
                  aiScore != null ? '$aiScore/100' : 'Chưa có',
                  StartupOnboardingTheme.goldAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: profileCompletion,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: StartupOnboardingTheme.goldAccent,
            strokeWidth: 6,
          ),
        ),
        Text(
          '${(profileCompletion * 100).toInt()}%',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: StartupOnboardingTheme.slateGray.withOpacity(0.8),
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
      case DashboardKycStatus.none: return StartupOnboardingTheme.slateGray;
      case DashboardKycStatus.pending: return Colors.orangeAccent;
      case DashboardKycStatus.verified: return Colors.greenAccent;
      case DashboardKycStatus.rejected: return Colors.redAccent;
    }
  }
}
