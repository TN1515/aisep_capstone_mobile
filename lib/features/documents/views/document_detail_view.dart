import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'document_versions_view.dart';
import 'edit_metadata_view.dart';
import 'package:flutter/services.dart';

class DocumentDetailView extends StatelessWidget {
  final DocumentModel document;
  final DocumentViewModel viewModel;

  const DocumentDetailView({
    super.key, 
    required this.document,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<DocumentViewModel>(
        builder: (context, vm, child) {
          // Luôn lấy dữ liệu mới nhất từ danh sách trong VM
          late DocumentModel currentDoc;
          try {
            currentDoc = vm.documents.firstWhere((d) => d.id == document.id);
          } catch (_) {
            currentDoc = document;
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Chi tiết tài liệu',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.edit3, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ChangeNotifierProvider.value(
                        value: vm,
                        child: EditMetadataView(document: currentDoc),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmation(context, vm, currentDoc),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: vm.isLoading && vm.documents.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header Card
                        _buildHeader(context, currentDoc),
                        const SizedBox(height: 24),

                        // 2. Action Buttons
                        _buildActionButtons(context, currentDoc),
                        const SizedBox(height: 32),

                        // 3. Information Section
                        _buildSectionTitle(context, 'Thông tin chung'),
                        const SizedBox(height: 16),
                        _buildInfoCard(context, currentDoc),
                        const SizedBox(height: 32),

                        // 4. IP Protection Section (Blockchain)
                        _buildSectionTitle(context, 'Bảo vệ IP (Blockchain)'),
                        const SizedBox(height: 16),
                        _buildBlockchainCard(context, vm, currentDoc),
                        const SizedBox(height: 32),

                        // 5. Version History Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle(context, 'Lịch sử phiên bản'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DocumentVersionsView(document: currentDoc))
                                );
                              },
                              child: Text(
                                'Xem tất cả',
                                style: GoogleFonts.workSans(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildVersionsPreview(context, currentDoc),
                        
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DocumentModel doc) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.fileText, color: theme.primaryColor, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            doc.displayTitle,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                context, 
                'Hiện tại', 
                Colors.green.withOpacity(0.1), 
                Colors.green
              ),
              const SizedBox(width: 8),
              if (doc.proofStatus == ProofStatus.none)
                _buildBadge(
                  context, 
                  'Chưa bảo vệ', 
                  Colors.orange.withOpacity(0.1), 
                  Colors.orange
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DocumentModel doc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Open URL
            },
            icon: const Icon(LucideIcons.externalLink, size: 18),
            label: const Text('Mở tệp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: isDark ? StartupOnboardingTheme.navyBg : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Download logic
            },
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Tải xuống'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, DocumentModel doc) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'Loại tài liệu', doc.documentType.label),
          _buildDivider(context),
          _buildInfoRow(context, 'Phiên bản', doc.version ?? '1.0'),
          _buildDivider(context),
          _buildInfoRow(context, 'Ngày tạo', dateFormat.format(doc.uploadDate)),
          _buildDivider(context),
          _buildInfoRow(context, 'Cập nhật', dateFormat.format(DateTime.now())), // Placeholder
        ],
      ),
    );
  }

  Widget _buildBlockchainCard(BuildContext context, DocumentViewModel vm, DocumentModel doc) {
    final theme = Theme.of(context);
    final status = doc.proofStatus;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        gradient: status == ProofStatus.anchored 
          ? LinearGradient(
              colors: [theme.cardColor, Colors.green.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.shieldCheck, color: status.color, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Trạng thái IP',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              _buildBadge(context, status.label.split('(')[0].trim(), status.color.withOpacity(0.1), status.color),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            status == ProofStatus.anchored
              ? 'Tài liệu này đã được xác thực an toàn trên Blockchain. Quyền sở hữu trí tuệ của bạn được bảo vệ với bằng chứng thời gian bất biến.'
              : status == ProofStatus.pending
                ? 'Giao dịch đang được xử lý trên mạng lưới Blockchain. Vui lòng chờ trong giây lát.'
                : 'Tài liệu chưa được bảo vệ. Gửi lên blockchain để đăng ký quyền sở hữu trí tuệ với bằng chứng thời gian.',
            style: GoogleFonts.workSans(
              fontSize: 13,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          
          if (status != ProofStatus.none && status != ProofStatus.failed) ...[
            const SizedBox(height: 24),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),
            
            _buildDetailedInfoRow(context, LucideIcons.layers, 'Phiên bản', 'v${doc.version ?? "1.0"}'),
            const SizedBox(height: 12),
            _buildDetailedInfoRow(context, LucideIcons.calendar, 'Ngày xác thực', dateFormat.format(doc.uploadDate)),
            const SizedBox(height: 12),
            _buildDetailedInfoRow(context, LucideIcons.globe, 'Mạng lưới', 'Sepolia (Ethereum)'),
            
            if (doc.fileHash != null) ...[
              const SizedBox(height: 16),
              _buildHashField(context, 'Mã Hash tệp (SHA-256)', doc.fileHash!),
            ],
            
            if (doc.transactionHash != null) ...[
              const SizedBox(height: 12),
              _buildHashField(context, 'Mã Giao dịch (TxHash)', doc.transactionHash!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final url = 'https://sepolia.etherscan.io/tx/${doc.transactionHash}';
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text('Đã sao chép liên kết Etherscan', style: GoogleFonts.workSans()),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 16),
                  label: const Text('Sao chép link Etherscan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],

          if (status == ProofStatus.none || status == ProofStatus.failed || status == ProofStatus.hashComputed) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: vm.isLoading ? null : () => vm.submitToChain(doc.id),
                icon: vm.isLoading 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(LucideIcons.shield, size: 18),
                label: Text(vm.isLoading ? 'Đang gửi...' : 'Bảo vệ tài liệu ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.brightness == Brightness.dark ? Colors.white : StartupOnboardingTheme.navyBg,
                  foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.primaryColor.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 13,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildHashField(BuildContext context, String label, String hash) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hash,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.copy, size: 14, color: theme.primaryColor.withOpacity(0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionsPreview(BuildContext context, DocumentModel doc) {
    final theme = Theme.of(context);
    final versions = doc.versions ?? [];
    
    if (versions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(
          'Chưa có lịch sử phiên bản.',
          style: GoogleFonts.workSans(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: versions.take(2).map((v) => _buildVersionTile(context, v)).toList(),
    );
  }

  Widget _buildVersionTile(BuildContext context, DocumentVersion version) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'v${version.version}',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tải lên bởi ${version.author}',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                Text(
                  dateFormat.format(version.date),
                  style: GoogleFonts.workSans(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 16, color: theme.dividerColor),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.workSans(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.workSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentViewModel vm, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa tài liệu này? Hành động này không thể hoàn tác.', style: GoogleFonts.workSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.workSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final success = await vm.deleteDocument(doc.id);
              if (success && context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa tài liệu')),
                );
              }
            },
            child: Text('Xóa', style: GoogleFonts.workSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Theme.of(context).dividerColor, height: 1),
    );
  }
}
