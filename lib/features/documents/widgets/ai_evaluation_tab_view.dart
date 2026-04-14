import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../evaluation/models/evaluation_models.dart';
import '../../evaluation/view_models/evaluation_view_model.dart';
import '../../../core/services/token_service.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import '../views/ai_report_detail_view.dart';
import 'package:intl/intl.dart';

class AiEvaluationTabView extends StatefulWidget {
  final EvaluationViewModel viewModel;
  final DocumentViewModel documentViewModel;

  const AiEvaluationTabView({
    super.key,
    required this.viewModel,
    required this.documentViewModel,
  });

  @override
  State<AiEvaluationTabView> createState() => _AiEvaluationTabViewState();
}

class _AiEvaluationTabViewState extends State<AiEvaluationTabView> {
  @override
  void initState() {
    super.initState();
    // Tự động load lịch sử khi mở tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<EvaluationViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final latest = vm.history.isNotEmpty ? vm.history.first : null;

        return RefreshIndicator(
          onRefresh: () => vm.loadHistory(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              if (latest != null && latest.status == EvaluationStatus.completed)
                _buildLatestResultHero(context, latest)
              else if (latest != null && latest.status == EvaluationStatus.processing)
                _buildProcessingHero(context)
              else
                _buildEmptyStateHero(context),
              const SizedBox(height: 24),
              _buildQuickActions(context, latest),
              const SizedBox(height: 100), // Spacing for scroll
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, EvaluationStatusResult? latest) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('HH:mm dd/MM/yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Đánh giá AI',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.displayLarge?.color,
                  ),
                ),
                if (latest != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: latest.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: latest.status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          latest.status.label,
                          style: GoogleFonts.workSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: latest.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (latest != null)
              Text(
                'Lần đánh giá gần nhất: ${dateFormat.format(latest.submittedAt)}',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
          ],
        ),
        IconButton(
          onPressed: () => _showSubmissionDialog(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final theme = Theme.of(context);
    // These values could be dynamic in the future
    final eligibleDocsCount = widget.documentViewModel.documents.where((doc) => 
      (doc.documentType == DocumentType.pitchDeck || doc.documentType == DocumentType.businessPlan) && 
      doc.proofStatus == ProofStatus.anchored
    ).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildSummaryCard(
            context,
            'Hồ sơ Startup',
            '69% hoàn thành',
            LucideIcons.userCheck,
            Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            context,
            'Tài liệu',
            '$eligibleDocsCount tài liệu hợp lệ',
            LucideIcons.fileCheck,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            context,
            'Phạm vi',
            'Đã hỗ trợ dữ liệu mới',
            LucideIcons.target,
            theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.workSans(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestResultHero(BuildContext context, EvaluationStatusResult latest) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart3, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Kết quả đánh giá gần nhất',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: (latest.overallScore ?? 0) / 100,
                        strokeWidth: 8,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      '${latest.overallScore?.toInt() ?? 0}',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Startup Potential Score',
                  style: GoogleFonts.workSans(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSubScoreBadge(context, 'Market', 85),
              _buildSubScoreBadge(context, 'Product', 70),
              _buildSubScoreBadge(context, 'Team', 90),
              _buildSubScoreBadge(context, 'Finance', 65),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (latest.isReportReady && latest.status == EvaluationStatus.completed)
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AiReportDetailView(
                                    evaluationId: latest.runId.toString())),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: theme.primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    latest.status == EvaluationStatus.processing 
                      ? 'Đang chuẩn bị báo cáo...' 
                      : 'Xem báo cáo chi tiết'
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubScoreBadge(BuildContext context, String label, int score) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
          ),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingHero(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            'Hệ thống đang phân tích...',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            'Vui lòng đợi trong giây lát, chuyên gia AI đang đánh giá Pitch Deck của bạn.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateHero(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.sparkles, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          Text(
            'Nâng tầm Startup với AI',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Khám phá tiềm năng đầu tư của dự án qua lăng kính chuyên gia AI.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showSubmissionDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Bắt đầu đánh giá ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, EvaluationStatusResult? latest) {
    final theme = Theme.of(context);
    final historyCount = widget.viewModel.history.length;
    
    return Column(
      children: [
        _buildActionCard(
          context,
          'Lịch sử đánh giá',
          historyCount > 0 ? '$historyCount lượt đánh giá' : 'Chưa có lịch sử',
          LucideIcons.history,
          historyCount > 0 ? () {
            // Future: Navigate to history list view
          } : null,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          'Báo cáo chi tiết mới nhất',
          latest != null 
            ? (latest.status == EvaluationStatus.processing ? 'Đang xử lý...' : 'Cập nhật: ${DateFormat('dd/MM').format(latest.submittedAt)}') 
            : 'Chưa có báo cáo',
          LucideIcons.fileText,
          (latest != null && latest.isReportReady && latest.status == EvaluationStatus.completed)
            ? () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AiReportDetailView(evaluationId: latest.runId.toString())),
                );
              }
            : null,
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback? onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.workSans(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: theme.dividerColor, size: 20),
          ],
        ),
      ),
    );
  }


  void _showSubmissionDialog(BuildContext context) {
    // Filter documents: Pitch Deck/Business Plan AND Anchored
    final eligibleDocs = widget.documentViewModel.documents.where((doc) => 
      (doc.documentType == DocumentType.pitchDeck || doc.documentType == DocumentType.businessPlan) && 
      doc.proofStatus == ProofStatus.anchored
    ).toList();

    if (eligibleDocs.isEmpty) {
      _showNoDocsMessage(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn tài liệu định danh (Anchored) để đánh giá',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Chỉ các tài liệu đã neo thành công trên Blockchain mới có thể được đánh giá bởi AI.',
                style: GoogleFonts.workSans(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: eligibleDocs.length,
                  itemBuilder: (context, index) {
                    final doc = eligibleDocs[index];
                    return ListTile(
                      leading: Icon(
                        doc.documentType == DocumentType.pitchDeck ? LucideIcons.presentation : LucideIcons.fileText,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(doc.displayTitle),
                      subtitle: Text('${doc.documentType.label} • Đã xác thực'),
                      onTap: () {
                        Navigator.pop(context);
                        _submit(context, doc);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoDocsMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không tìm thấy tài liệu hợp lệ'),
        content: const Text('Bạn cần có Pitch Deck hoặc Business Plan đã được neo (Anchored) trên Blockchain thành công trước khi thực hiện đánh giá AI.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context, DocumentModel doc) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang gửi yêu cầu đánh giá...')),
    );

    final userIdStr = await TokenService.getUserId();
    final int? startupId = int.tryParse(userIdStr ?? '');

    await widget.viewModel.submitForEvaluation(startupId, [doc.id]);

    if (widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${widget.viewModel.errorMessage}'), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi thành công! Đang tiến hành phân tích...'), backgroundColor: Colors.green),
      );
    }
  }
}

