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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lịch sử phiên bản'),
      ),
      body: Consumer<DocumentViewModel>(
        builder: (context, viewModel, child) {
          final versions = document.versions ?? [];
          
          if (versions.isEmpty) {
            return _buildEmptyVersions(context);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderInfo(context),
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

  Widget _buildHeaderInfo(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            theme.cardColor.withOpacity(0.5),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(LucideIcons.fileText, color: theme.primaryColor),
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
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Phiên bản hiện tại: ${document.version ?? "1.0"}',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: theme.primaryColor,
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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
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
                  color: isCurrent ? theme.primaryColor : textColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
              ),
              Container(
                width: 2,
                height: 100, // Adjust height based on content
                color: theme.dividerColor,
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Content Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCurrent ? theme.primaryColor.withOpacity(0.05) : theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent ? theme.primaryColor.withOpacity(0.3) : theme.dividerColor,
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
                          color: isCurrent ? theme.primaryColor : textColor,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HIỆN TẠI',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, LucideIcons.calendar, dateFormat.format(version.date)),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, LucideIcons.user, version.author),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, LucideIcons.hardDrive, '${version.sizeInMb.toStringAsFixed(1)} MB'),
                  
                  if (!isCurrent) ...[
                    const SizedBox(height: 16),
                    Divider(color: theme.dividerColor),
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
                            foregroundColor: theme.primaryColor,
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

  Widget _buildDetailRow(BuildContext context, IconData icon, String value) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Row(
      children: [
        Icon(icon, size: 14, color: textColor.withOpacity(0.4)),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.workSans(
            fontSize: 13,
            color: textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyVersions(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 64, color: theme.primaryColor.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'Chưa có lịch sử phiên bản',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
