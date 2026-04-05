import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class ConsultingReportView extends StatelessWidget {
  final ConsultingSessionModel session;

  const ConsultingReportView({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

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
          'Báo cáo Tư vấn',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download, color: StartupOnboardingTheme.goldAccent),
            onPressed: () {
              ToastUtils.showTopToast(context, 'Đang tải báo cáo xuống...');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(dateFormat),
            const SizedBox(height: 32),
            Text(
              'Nội dung báo cáo',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
            ),
            const SizedBox(height: 16),
            if (session.reportCards != null)
              ...session.reportCards!.map((cardText) => _buildReportSection(cardText)).toList()
            else
              _buildEmptyReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.fileText, color: StartupOnboardingTheme.goldAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.objective,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
                ),
                Text(
                  'Hoàn tất ngày: ${session.completedAt != null ? dateFormat.format(session.completedAt!) : 'N/A'}',
                  style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(String text) {
    final parts = text.split(':');
    final title = parts.isNotEmpty ? parts[0] : 'Section';
    final content = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.goldAccent),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.workSans(fontSize: 14, color: StartupOnboardingTheme.softIvory, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReport() {
    return Center(
      child: Text(
        'Chưa có nội dung báo cáo chi tiết.',
        style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
      ),
    );
  }
}
