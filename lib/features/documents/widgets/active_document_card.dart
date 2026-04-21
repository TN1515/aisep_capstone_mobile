import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/document_model.dart';
import 'package:intl/intl.dart';

class ActiveDocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;

  const ActiveDocumentCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildFileIcon(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.displayTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildReviewStatusChip(context),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        document.documentType.label,
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: textColor.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(document.uploadDate),
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    IconData icon;
    Color color;

    if (document.fileName.endsWith('.pdf')) {
      icon = LucideIcons.fileText;
      color = Colors.redAccent.withOpacity(0.8);
    } else if (document.fileName.endsWith('.xlsx') || document.fileName.endsWith('.csv')) {
      icon = LucideIcons.fileSpreadsheet;
      color = Colors.greenAccent.withOpacity(0.8);
    } else {
      icon = LucideIcons.file;
      color = Theme.of(context).primaryColor.withOpacity(0.8);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildReviewStatusChip(BuildContext context) {
    String label;
    Color color;

    switch (document.reviewStatus) {
      case DocumentReviewStatus.approved:
        label = 'Đã duyệt';
        color = Colors.greenAccent;
        break;
      case DocumentReviewStatus.verified:
        label = 'Đã xác minh';
        color = Colors.blueAccent;
        break;
      case DocumentReviewStatus.rejected:
        label = 'Bị từ chối';
        color = Colors.redAccent;
        break;
      case DocumentReviewStatus.pending:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
