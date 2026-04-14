import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';

class BlockchainStatusCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onAction; // Unified action based on status
  final VoidCallback? onTap;

  const BlockchainStatusCard({
    super.key,
    required this.document,
    required this.onAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = document.proofStatus;
    final bool isAnchored = status == ProofStatus.anchored;
    final bool isPending = status == ProofStatus.pending;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isAnchored 
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
              _buildStatusIcon(context, status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.displayTitle,
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
                      status.label,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: status.color.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAnchored)
                const Icon(LucideIcons.checkCircle2, color: Colors.greenAccent, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          if (document.transactionHash != null && document.transactionHash!.isNotEmpty) ...[
            _buildInfoRow(context, 'Transaction Hash', document.transactionHash!),
            const SizedBox(height: 12),
          ],
          if (document.fileHash != null && document.fileHash!.isNotEmpty) ...[
            _buildInfoRow(context, 'File Hash (SHA256)', document.fileHash!),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          _buildActionButton(context, status),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, ProofStatus status) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIcon(status),
        color: status.color,
        size: 24,
      ),
    );
  }

  IconData _getIcon(ProofStatus status) {
    switch (status) {
      case ProofStatus.anchored: return LucideIcons.shieldCheck;
      case ProofStatus.pending: return LucideIcons.refreshCw;
      case ProofStatus.hashComputed: return LucideIcons.binary;
      case ProofStatus.failed: return LucideIcons.shieldAlert;
      case ProofStatus.none: return LucideIcons.shield;
    }
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

  Widget _buildActionButton(BuildContext context, ProofStatus status) {
    final theme = Theme.of(context);
    String label = 'Bảo vệ sở hữu trí tuệ';
    IconData icon = LucideIcons.zap;
    
    if (status == ProofStatus.anchored) {
      label = 'Xác minh tính toàn vẹn';
      icon = LucideIcons.checkSquare;
    } else if (status == ProofStatus.pending) {
      label = 'Đang kiểm tra giao dịch...';
      icon = LucideIcons.loader2;
    } else if (status == ProofStatus.hashComputed) {
      label = 'Gửi lên Blockchain';
      icon = LucideIcons.share2;
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: status == ProofStatus.pending ? null : onAction,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: status.color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: status.color),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: status.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
