import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/connection_model.dart';
import '../models/connection_request_model.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/connection_status_badge.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'connection_request_form_view.dart';

class ConnectionRequestDetailView extends StatelessWidget {
  final ConnectionModel connection;
  // In a real app, we'd fetch the full RequestModel using requestId
  final String? requestId;

  const ConnectionRequestDetailView({
    Key? key,
    required this.connection,
    this.requestId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel();
    final Color textColor = StartupOnboardingTheme.softIvory;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: StartupOnboardingTheme.navyBg,
          appBar: AppBar(
            backgroundColor: StartupOnboardingTheme.navyBg,
            elevation: 0,
            title: Text(
              'Chi tiết kết nối',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.softIvory,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSummary(),
                const SizedBox(height: 32),
                _buildMessageSection(textColor),
                const SizedBox(height: 32),
                _buildTimelineSection(textColor),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(context, viewModel),
        );
      },
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                child: const Icon(LucideIcons.user, color: StartupOnboardingTheme.goldAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.name,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: StartupOnboardingTheme.softIvory,
                      ),
                    ),
                    Text(
                      '${connection.position}${connection.organization != null ? ' @ ${connection.organization}' : ''}',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: StartupOnboardingTheme.softIvory.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ConnectionStatusBadge(status: connection.status),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactMetric('Độ phù hợp', '${(connection.matchScore * 100).toInt()}%'),
              _buildCompactMetric('Cập nhật', DateFormat('dd/MM/yyyy').format(connection.lastUpdated)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(fontSize: 10, color: StartupOnboardingTheme.softIvory.withOpacity(0.4)),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
        ),
      ],
    );
  }

  Widget _buildMessageSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('LỜI NHẮN KẾT NỐI'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StartupOnboardingTheme.navySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
          ),
          child: Text(
            connection.bio ?? 'Không có lời nhắn đi kèm.',
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('DÒNG THỜI GIAN'),
        const SizedBox(height: 20),
        _buildTimelineTile('Gửi yêu cầu', 'Yêu cầu kết nối đã được gửi thành công.', connection.lastUpdated, true),
        _buildTimelineTile('Nhà đầu tư đã xem', 'Yêu cầu của bạn đã được hiển thị cho đối tác.', connection.lastUpdated.add(const Duration(minutes: 15)), false),
      ],
    );
  }

  Widget _buildTimelineTile(String title, String desc, DateTime time, bool isFirst) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.goldAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory)),
              Text(desc, style: GoogleFonts.workSans(fontSize: 11, color: StartupOnboardingTheme.softIvory.withOpacity(0.5))),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm - dd/MM/yyyy').format(time), style: GoogleFonts.workSans(fontSize: 10, color: StartupOnboardingTheme.goldAccent.withOpacity(0.4))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: StartupOnboardingTheme.goldAccent,
      ),
    );
  }

  Widget? _buildBottomActions(BuildContext context, ConnectionViewModel vm) {
    if (connection.status == ConnectionStatus.received) {
      return _buildReceiverActions(context, vm);
    } else if (connection.status == ConnectionStatus.pending) {
      return _buildSenderActions(context, vm);
    }
    return null;
  }

  Widget _buildReceiverActions(BuildContext context, ConnectionViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      color: StartupOnboardingTheme.navyBg,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmAction(context, 'Từ chối', () => vm.rejectRequest(connection.id)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Từ chối', style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => vm.acceptRequest(connection.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Chấp nhận', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderActions(BuildContext context, ConnectionViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      color: StartupOnboardingTheme.navyBg,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmAction(context, 'Hủy yêu cầu', () => vm.cancelRequest(connection.id)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: StartupOnboardingTheme.softIvory.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Hủy yêu cầu', style: GoogleFonts.outfit(color: StartupOnboardingTheme.softIvory, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                 // In a real app, map the connection data to InvestorModel
                 // For now, navigate back to Hub for simplification
                 Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StartupOnboardingTheme.goldAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Cập nhật', style: GoogleFonts.outfit(color: StartupOnboardingTheme.navyBg, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String actionDesc, VoidCallback onConfirm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StartupOnboardingTheme.navyBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertTriangle, color: StartupOnboardingTheme.goldAccent, size: 48),
            const SizedBox(height: 24),
            Text(
              'Xác nhận $actionDesc?',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
            ),
            const SizedBox(height: 12),
            Text(
              'Hành động này không thể hoàn tác. Bạn có chắc chắn muốn tiếp tục?',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy', style: GoogleFonts.outfit(color: StartupOnboardingTheme.softIvory.withOpacity(0.4))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
