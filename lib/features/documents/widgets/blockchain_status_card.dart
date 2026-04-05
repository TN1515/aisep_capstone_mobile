import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';

class BlockchainStatusCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onVerify;

  const BlockchainStatusCard({
    super.key,
    required this.document,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isVerified = document.status == DocumentStatus.verified || document.status == DocumentStatus.aiCompleted;
    final bool isPending = document.status == DocumentStatus.pendingBlockchain || document.status == DocumentStatus.hashing;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isVerified 
            ? Colors.greenAccent.withOpacity(0.2) 
            : isPending 
              ? theme.primaryColor.withOpacity(0.2)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIcon(context, isVerified, isPending),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVerified ? 'Tài liệu đã được xác thực on-chain' : isPending ? 'Đang chờ xác thực...' : 'Chưa được xác thực',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                const Icon(LucideIcons.checkCircle2, color: Colors.greenAccent, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          if (document.txHash != null) ...[
            _buildInfoRow(context, 'Transaction Hash', document.txHash!),
            const SizedBox(height: 12),
          ],
          if (document.fileHash != null) ...[
            _buildInfoRow(context, 'File Hash (SHA256)', document.fileHash!),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          _buildActionButton(context, isVerified, isPending),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, bool isVerified, bool isPending) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isVerified 
          ? Colors.greenAccent.withOpacity(0.1) 
          : isPending 
            ? theme.primaryColor.withOpacity(0.1)
            : theme.scaffoldBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isVerified ? LucideIcons.shieldCheck : isPending ? LucideIcons.refreshCw : LucideIcons.shieldAlert,
        color: isVerified ? Colors.greenAccent : isPending ? theme.primaryColor : textColor.withOpacity(0.3),
        size: 24,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.workSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: theme.primaryColor.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: textColor.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.copy, size: 14, color: textColor.withOpacity(0.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isVerified, bool isPending) {
    if (isPending) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onVerify,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isVerified ? Colors.greenAccent.withOpacity(0.3) : theme.primaryColor.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVerified ? LucideIcons.externalLink : LucideIcons.zap, 
              size: 16, 
              color: isVerified ? Colors.greenAccent : theme.primaryColor
            ),
            const SizedBox(width: 12),
            Text(
              isVerified ? 'Xem trên Blockchain' : 'Yêu cầu xác thực ngay',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isVerified ? Colors.greenAccent : theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
