import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';

class DocumentVersionsView extends StatelessWidget {
  final DocumentModel document;

  const DocumentVersionsView({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: StartupOnboardingTheme.softIvory),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử phiên bản',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: Consumer<DocumentViewModel>(
        builder: (context, viewModel, child) {
          final versions = document.versions ?? [];
          
          if (versions.isEmpty) {
            return _buildEmptyVersions();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderInfo(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  itemCount: versions.length,
                  itemBuilder: (context, index) {
                    final version = versions[versions.length - 1 - index]; // Show latest first
                    final isCurrent = version.version == document.version;
                    
                    return _buildVersionItem(context, version, isCurrent, viewModel);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StartupOnboardingTheme.navySurface,
            StartupOnboardingTheme.navySurface.withOpacity(0.5),
          ],
        ),
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
                  document.fileName,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.softIvory,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Phiên bản hiện tại: ${document.version ?? "1.0"}',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: StartupOnboardingTheme.goldAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(BuildContext context, DocumentVersion version, bool isCurrent, DocumentViewModel viewModel) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCurrent ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
              ),
              Container(
                width: 2,
                height: 100, // Adjust height based on content
                color: StartupOnboardingTheme.softIvory.withOpacity(0.05),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Content Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCurrent ? StartupOnboardingTheme.goldAccent.withOpacity(0.05) : StartupOnboardingTheme.navySurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent ? StartupOnboardingTheme.goldAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Version ${version.version}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: StartupOnboardingTheme.goldAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HIỆN TẠI',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: StartupOnboardingTheme.navyBg,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(LucideIcons.calendar, dateFormat.format(version.date)),
                  const SizedBox(height: 8),
                  _buildDetailRow(LucideIcons.user, version.author),
                  const SizedBox(height: 8),
                  _buildDetailRow(LucideIcons.hardDrive, '${version.sizeInMb.toStringAsFixed(1)} MB'),
                  
                  if (!isCurrent) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.05)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            viewModel.restoreVersion(document.id, version.id);
                            ToastUtils.showTopToast(context, 'Đã phục hồi phiên bản ${version.version}');
                          },
                          icon: const Icon(LucideIcons.refreshCw, size: 14),
                          label: const Text('Phục hồi'),
                          style: TextButton.styleFrom(
                            foregroundColor: StartupOnboardingTheme.goldAccent,
                            textStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: StartupOnboardingTheme.softIvory.withOpacity(0.4)),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.workSans(
            fontSize: 13,
            color: StartupOnboardingTheme.softIvory.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyVersions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 64, color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'Chưa có lịch sử phiên bản',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
        ],
      ),
    );
  }
}
