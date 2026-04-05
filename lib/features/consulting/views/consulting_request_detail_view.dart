import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/status_badge.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/session_timeline.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/confirm_schedule_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/payment_checkout_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/consulting_report_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/feedback_form_view.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConsultingRequestDetailView extends StatelessWidget {
  final ConsultingSessionModel session;

  const ConsultingRequestDetailView({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chi tiết buổi tư vấn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdvisorProfileHeader(),
            const SizedBox(height: 24),
            SessionTimeline(currentStatus: session.status),
            const SizedBox(height: 24),
            _buildInfoCard('Nội dung yêu cầu', [
              _buildDetailRow('Mục tiêu', session.objective),
              _buildDetailRow('Phạm vi', session.scope),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Hình thức & Lịch hẹn', [
              _buildDetailRow('Hình thức', session.mode == ConsultingMode.online ? 'Trực tuyến' : 'Trực tiếp'),
              _buildDetailRow('Ngày giờ', session.scheduledAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(session.scheduledAt!) : 'Chưa xếp lịch'),
            ]),
            if (session.status == ConsultingStatus.paid || session.status == ConsultingStatus.conducted || session.status == ConsultingStatus.completed) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Thông tin thanh toán', [
                _buildDetailRow('Số tiền', NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(session.amount)),
                _buildDetailRow('Trạng thái', 'Đã thanh toán'),
                _buildDetailRow('Mã giao dịch', session.txHash ?? 'N/A'),
              ]),
            ],
            if (session.feedbackRating != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Phản hồi của bạn', [
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < session.feedbackRating! ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: StartupOnboardingTheme.goldAccent,
                    size: 20,
                  )),
                ),
                const SizedBox(height: 12),
                Text(
                  session.feedbackComment ?? '',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: StartupOnboardingTheme.softIvory.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]),
            ],
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(session.advisor?.avatarUrl ?? ''),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.advisor?.name ?? 'Unknown',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
                ),
                Text(
                  session.advisor?.title ?? '',
                  style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.goldAccent),
                ),
              ],
            ),
          ),
          StatusBadge(status: session.status),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory.withOpacity(0.4)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.workSans(fontSize: 14, color: StartupOnboardingTheme.softIvory, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (session.status) {
      case ConsultingStatus.requested:
        return _buildFullWidthButton('Hủy yêu cầu', Colors.redAccent.withOpacity(0.1), Colors.redAccent, () => _confirmCancel(context));
      case ConsultingStatus.proposed:
        return _buildFullWidthButton('Xác nhận lịch hẹn', StartupOnboardingTheme.goldAccent, StartupOnboardingTheme.navyBg, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmScheduleView(session: session)));
        });
      case ConsultingStatus.payable:
        return _buildFullWidthButton('Thanh toán ngay', StartupOnboardingTheme.goldAccent, StartupOnboardingTheme.navyBg, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentCheckoutView(session: session)));
        });
      case ConsultingStatus.conducted:
        return _buildFullWidthButton('Xác nhận hoàn tất', StartupOnboardingTheme.goldAccent, StartupOnboardingTheme.navyBg, () {
          context.read<ConsultingViewModel>().updateSessionStatus(session.id, ConsultingStatus.completed);
          ToastUtils.showTopToast(context, 'Buổi tư vấn đã hoàn tất. Vui lòng để lại đánh giá!');
          // Smooth transition to feedback
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FeedbackFormView(session: session)));
        });
      case ConsultingStatus.completed:
        return Column(
          children: [
            _buildFullWidthButton('Xem báo cáo tư vấn', StartupOnboardingTheme.navySurface, StartupOnboardingTheme.goldAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ConsultingReportView(session: session)));
            }, isOutlined: true),
            const SizedBox(height: 16),
            if (session.feedbackRating == null)
              _buildFullWidthButton('Gửi phản hồi', StartupOnboardingTheme.goldAccent, StartupOnboardingTheme.navyBg, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackFormView(session: session)));
              }),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFullWidthButton(String text, Color bgColor, Color textColor, VoidCallback onPressed, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: textColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StartupOnboardingTheme.navySurface,
        title: Text('Xác nhận hủy', style: GoogleFonts.outfit(color: StartupOnboardingTheme.softIvory)),
        content: Text('Bạn có chắc chắn muốn hủy yêu cầu tư vấn này?', style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
          TextButton(
            onPressed: () {
              context.read<ConsultingViewModel>().updateSessionStatus(session.id, ConsultingStatus.cancelled);
              ToastUtils.showTopToast(context, 'Yêu cầu của bạn đã được hủy.');
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Hủy yêu cầu', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
