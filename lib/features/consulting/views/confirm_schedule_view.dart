import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/payment_checkout_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConfirmScheduleView extends StatelessWidget {
  final ConsultingSessionModel session;

  const ConfirmScheduleView({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Xác nhận lịch hẹn',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: StartupOnboardingTheme.navySurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.calendarCheck, color: StartupOnboardingTheme.goldAccent, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lịch hẹn dự kiến',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
                  ),
                  const SizedBox(height: 24),
                  _buildReviewRow(LucideIcons.user, 'Cố vấn', session.advisor?.name ?? ''),
                  const SizedBox(height: 16),
                  _buildReviewRow(LucideIcons.calendar, 'Ngày', session.scheduledAt != null ? dateFormat.format(session.scheduledAt!) : 'TBA'),
                  const SizedBox(height: 16),
                  _buildReviewRow(LucideIcons.clock, 'Giờ', session.scheduledAt != null ? timeFormat.format(session.scheduledAt!) : 'TBA'),
                  const SizedBox(height: 16),
                  _buildReviewRow(LucideIcons.mapPin, 'Hình thức', session.mode == ConsultingMode.online ? 'Trực tuyến' : 'Trực tiếp'),
                  const SizedBox(height: 16),
                  _buildReviewRow(LucideIcons.creditCard, 'Chi phí', NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(session.amount)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Bước tiếp theo: Sau khi xác nhận lịch hẹn này, bạn có thể thực hiện thanh toán để hoàn tất đăng ký.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.5))),
        const Spacer(),
        Text(value, style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Hủy bỏ', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Confirm schedule and move to payable
                context.read<ConsultingViewModel>().updateSessionStatus(session.id, ConsultingStatus.payable);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentCheckoutView(session: session)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StartupOnboardingTheme.goldAccent,
                foregroundColor: StartupOnboardingTheme.navyBg,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Tiếp tục & Thanh toán', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
