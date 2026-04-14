import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/mentorship_models.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/payment_checkout_webview.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MentorshipDetailView extends StatelessWidget {
  final MentorshipDto mentorship;

  const MentorshipDetailView({Key? key, required this.mentorship}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Chi tiết Cố vấn',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context),
            const SizedBox(height: 32),
            _buildAdvisorSection(context),
            const SizedBox(height: 32),
            _buildDetailSection(context, 'Thách thức của Startup', mentorship.challengeDescription ?? ''),
            const SizedBox(height: 24),
            _buildDetailSection(context, 'Câu hỏi cụ thể', mentorship.specificQuestions ?? ''),
            const SizedBox(height: 24),
            _buildInfoGrid(context),
            const SizedBox(height: 32),
            if (mentorship.sessions.isNotEmpty) ...[
              _buildSessionsSection(context),
              const SizedBox(height: 32),
            ],
            if (mentorship.reports.isNotEmpty) ...[
              _buildReportsSection(context),
              const SizedBox(height: 32),
            ],
            _buildTimeline(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, currencyFormat),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _getStatusIcon(mentorship.status),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(mentorship.status),
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getStatusSubtext(mentorship.status),
                  style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorSection(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: mentorship.advisorAvatar != null ? NetworkImage(mentorship.advisorAvatar!) : null,
          child: mentorship.advisorAvatar == null ? const Icon(LucideIcons.user) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mentorship.advisorName ?? 'Advisor',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Chuyên gia Tư vấn',
                style: GoogleFonts.workSans(fontSize: 13, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(LucideIcons.messageCircle, color: Theme.of(context).primaryColor),
        ),
      ],
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.workSans(
            fontSize: 14,
            height: 1.5,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(LucideIcons.video, 'Hình thức', mentorship.preferredFormat ?? 'Video Call'),
          const Divider(height: 24),
          _buildInfoRow(LucideIcons.clock, 'Thời lượng', mentorship.expectedDuration ?? '1 tháng'),
          const Divider(height: 24),
          _buildInfoRow(LucideIcons.layers, 'Phạm vi', mentorship.expectedScope ?? 'Cơ bản'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.workSans(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Text(value, style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSessionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch hẹn tư vấn',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...mentorship.sessions.map((session) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.video, size: 18, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(session.scheduledStartAt),
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Thời lượng: ${session.durationMinutes} phút',
                      style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (session.meetingURL != null) 
                TextButton(
                  onPressed: () {}, // Launch URL
                  child: const Text('Tham gia'),
                ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReportsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Báo cáo cố vấn',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...mentorship.reports.map((report) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.fileText, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    report.summary,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.recommendations,
                style: GoogleFonts.workSans(fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Ngày gửi: ${DateFormat('dd/MM/yyyy').format(report.submittedAt)}',
                style: GoogleFonts.workSans(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến trình',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        _buildTimelineStep(context, 'Gửi yêu cầu', 'Startup đã gửi yêu cầu tư vấn.', true),
        _buildTimelineStep(context, 'Advisor phản hồi', 'Advisor đang xem xét yêu cầu của bạn.', 
            mentorship.status != MentorshipStatus.requested && mentorship.status != MentorshipStatus.rejected),
        _buildTimelineStep(context, 'Thanh toán', 'Thanh toán phí tư vấn để bắt đầu.', 
            mentorship.status == MentorshipStatus.inProgress || mentorship.status == MentorshipStatus.completed),
        _buildTimelineStep(context, 'Hoàn thành', 'Buổi tư vấn kết thúc và nhận báo cáo.', 
            mentorship.status == MentorshipStatus.completed, isLast: true),
      ],
    );
  }

  Widget _buildTimelineStep(BuildContext context, String title, String sub, bool isDone, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isDone ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDone ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDone ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
                ),
              ),
              Text(
                sub,
                style: GoogleFonts.workSans(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, NumberFormat currencyFormat) {
    // We assume the caller or a global state determines if current user is Advisor
    // For this mapping, we'll provide buttons that the Advisor role would need
    
    if (mentorship.status == MentorshipStatus.accepted) {
      return Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFormat.format(mentorship.price),
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor),
                ),
                Text('Phí tư vấn', style: GoogleFonts.workSans(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                   Expanded(
                    child: OutlinedButton(
                      onPressed: () {}, // Navigate to Chat
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Icon(LucideIcons.messageCircle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _handlePayment(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text('Thanh toán', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (mentorship.status == MentorshipStatus.requested) {
      return Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleResponse(context, MentorshipStatus.rejected),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Colors.redAccent),
                ),
                child: Text('Từ chối', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.redAccent)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleResponse(context, MentorshipStatus.accepted),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Chấp nhận', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    if (mentorship.status == MentorshipStatus.inProgress || mentorship.status == MentorshipStatus.completed) {
       return Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: ElevatedButton.icon(
          onPressed: () {}, // Navigate to Chat
          icon: const Icon(LucideIcons.messageSquare),
          label: const Text('Nhắn tin trao đổi'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _handleResponse(BuildContext context, MentorshipStatus status) async {
    final viewModel = context.read<ConsultingViewModel>();
    try {
      await viewModel.respondToMentorshipRequest(mentorship.id, status);
      if (context.mounted) {
        ToastUtils.showTopToast(context, status == MentorshipStatus.accepted ? 'Đã chấp nhận yêu cầu' : 'Đã từ chối yêu cầu');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showTopToast(context, 'Có lỗi xảy ra khi thực hiện thao tác');
      }
    }
  }

  void _handlePayment(BuildContext context) async {
    final viewModel = context.read<ConsultingViewModel>();
    try {
      final paymentInfo = await viewModel.createMentorshipPaymentLink(mentorship.id);
      if (paymentInfo != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentCheckoutWebView(
              checkoutUrl: paymentInfo.checkoutUrl,
              orderCode: paymentInfo.orderCode,
            ),
          ),
        );
      }
    } catch (e) {
      ToastUtils.showTopToast(context, 'Không thể tạo liên kết thanh toán');
    }
  }

  Icon _getStatusIcon(MentorshipStatus status) {
    switch (status) {
      case MentorshipStatus.requested: return const Icon(LucideIcons.send, color: Colors.blue);
      case MentorshipStatus.accepted: return const Icon(LucideIcons.checkCircle, color: Colors.green);
      case MentorshipStatus.inProgress: return const Icon(LucideIcons.playCircle, color: Colors.orange);
      case MentorshipStatus.completed: return const Icon(LucideIcons.award, color: Colors.grey);
      case MentorshipStatus.cancelled:
      case MentorshipStatus.rejected: return const Icon(LucideIcons.xCircle, color: Colors.red);
    }
  }

  String _getStatusText(MentorshipStatus status) {
    switch (status) {
      case MentorshipStatus.requested: return 'Đang chờ xử lý';
      case MentorshipStatus.accepted: return 'Yêu cầu được chấp nhận';
      case MentorshipStatus.inProgress: return 'Đang trong quá trình';
      case MentorshipStatus.completed: return 'Đã hoàn thành';
      case MentorshipStatus.cancelled: return 'Đã hủy';
      case MentorshipStatus.rejected: return 'Đã từ chối';
    }
  }

  String _getStatusSubtext(MentorshipStatus status) {
    switch (status) {
      case MentorshipStatus.requested: return 'Advisor sẽ phản hồi trong vòng 24-48h.';
      case MentorshipStatus.accepted: return 'Vui lòng thực hiện thanh toán để bắt đầu.';
      case MentorshipStatus.inProgress: return 'Cuộc họp đang được chuẩn bị.';
      case MentorshipStatus.completed: return 'Cảm ơn bạn đã sử dụng dịch vụ.';
      case MentorshipStatus.cancelled:
      case MentorshipStatus.rejected: return 'Liên hệ hỗ trợ nếu bạn có thắc mắc.';
    }
  }
}
