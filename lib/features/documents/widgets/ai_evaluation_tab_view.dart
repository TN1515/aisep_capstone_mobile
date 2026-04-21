import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../evaluation/view_models/evaluation_view_model.dart';
import '../../evaluation/models/evaluation_models.dart';
import '../../evaluation/views/evaluation_submission_view.dart';
import '../../evaluation/views/evaluation_report_view.dart';
import '../../profile/view_models/startup_profile_view_model.dart';
import '../view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = context.read<StartupProfileViewModel>();
      widget.viewModel.loadHistory(profileVm.startupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<EvaluationViewModel>();

    return Column(
      children: [
        _buildLiveProcessingBanner(viewModel),
        Expanded(
          child: viewModel.isLoading && viewModel.history.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _buildHistoryList(viewModel),
        ),
      ],
    );
  }

  Widget _buildLiveProcessingBanner(EvaluationViewModel viewModel) {
    final processingItems = viewModel.history.where((e) => 
      e.status == EvaluationStatus.processing || e.status == EvaluationStatus.queued
    ).toList();

    if (processingItems.isEmpty) return const SizedBox.shrink();

    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI đang phân tích tài liệu...',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    'Bạn có thể tiếp tục xem tài liệu, chúng tôi sẽ cập nhật kết quả tại đây.',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(EvaluationViewModel viewModel) {
    if (viewModel.history.isEmpty && !viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.barChart2, size: 64, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử đánh giá',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EvaluationSubmissionView()),
                );
              },
              icon: const Icon(LucideIcons.plusCircle),
              label: const Text('Bắt đầu đánh giá ngay'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        final profileVm = context.read<StartupProfileViewModel>();
        return viewModel.loadHistory(profileVm.startupId);
      },
      color: StartupOnboardingTheme.goldAccent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: viewModel.history.length,
        itemBuilder: (context, index) {
          final item = viewModel.history[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: _buildHistoryCard(item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(EvaluationStatusResult item) {
    bool isCompleted = item.status == EvaluationStatus.completed;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted 
              ? theme.primaryColor.withOpacity(0.1) 
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: isCompleted ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluationReportView(runId: item.runId),
            ),
          );
        } : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Lần đánh giá #${item.runId}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),
            _buildStatusBadge(item.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Ngày gửi: ${DateFormat('dd/MM/yyyy HH:mm').format(item.submittedAt)}',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (isCompleted && item.overallScore != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    'Điểm Startup: ',
                    style: GoogleFonts.workSans(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    '${item.overallScore!.toStringAsFixed(1)}/10',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
            if (item.status == EvaluationStatus.failed) ...[
              const SizedBox(height: 8),
              Text(
                'Lỗi: ${item.failureReason ?? "Không xác định"}',
                style: GoogleFonts.workSans(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ],
        ),
        trailing: isCompleted 
            ? Icon(LucideIcons.chevronRight, color: theme.primaryColor)
            : null,
      ),
    );
  }

  Widget _buildStatusBadge(EvaluationStatus status) {
    Color statusColor = status.color;
    String statusLabel = status.label;

    // Additional styling for specific statuses if needed
    if (status == EvaluationStatus.partial_completed) {
      statusColor = Colors.cyan.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        statusLabel,
        style: GoogleFonts.workSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }
}
