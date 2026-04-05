import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;

  const DocumentCard({
    Key? key,
    required this.document,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFileIcon(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.fileName,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: StartupOnboardingTheme.softIvory,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${document.type} • ${DateFormat('dd/MM/yyyy').format(document.uploadDate)}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: StartupOnboardingTheme.slateGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                if (document.status != DocumentStatus.verified && document.status != DocumentStatus.failed) ...[
                  const SizedBox(height: 16),
                  _buildProgressBar(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    IconData iconData = LucideIcons.fileText;
    if (document.fileName.toLowerCase().endsWith('.pdf')) iconData = LucideIcons.fileText;
    if (document.fileName.toLowerCase().endsWith('.xlsx') || document.fileName.toLowerCase().endsWith('.csv')) iconData = LucideIcons.fileText;
    if (document.fileName.toLowerCase().contains('pitch')) iconData = LucideIcons.layout;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navyBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: StartupOnboardingTheme.goldAccent, size: 24),
    );
  }

  Widget _buildStatusBadge() {
    Color color = StartupOnboardingTheme.goldAccent;
    IconData icon = LucideIcons.clock;
    String label = 'Đang xử lý';

    switch (document.status) {
      case DocumentStatus.uploaded:
        label = 'Đã tải lên';
        break;
      case DocumentStatus.hashing:
        label = 'Đang băm';
        break;
      case DocumentStatus.pendingBlockchain:
        label = 'Chờ Blockchain';
        break;
      case DocumentStatus.verified:
        color = const Color(0xFF10B981);
        icon = LucideIcons.shieldCheck;
        label = 'Đã xác thực';
        break;
      case DocumentStatus.failed:
      case DocumentStatus.blockchainFailed:
        color = const Color(0xFFEF4444);
        icon = LucideIcons.alertTriangle;
        label = 'Thất bại';
        break;
      case DocumentStatus.aiEvaluating:
        label = 'Đang đánh giá';
        break;
      case DocumentStatus.aiCompleted:
        color = const Color(0xFF10B981);
        icon = LucideIcons.checkCircle;
        label = 'Đã đánh giá';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = 0.2;
    if (document.status == DocumentStatus.hashing) progress = 0.5;
    if (document.status == DocumentStatus.pendingBlockchain) progress = 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến trình xác thực',
              style: GoogleFonts.workSans(
                fontSize: 10,
                color: StartupOnboardingTheme.slateGray,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.workSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.goldAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(StartupOnboardingTheme.goldAccent),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
