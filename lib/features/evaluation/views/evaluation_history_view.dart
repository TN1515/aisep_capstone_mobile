import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../profile/view_models/startup_profile_view_model.dart';
import '../view_models/evaluation_view_model.dart';
import '../models/evaluation_models.dart';
import '../../../core/theme/startup_onboarding_theme.dart';
import 'evaluation_submission_view.dart';
import 'evaluation_report_view.dart';

class EvaluationHistoryView extends StatefulWidget {
  const EvaluationHistoryView({Key? key}) : super(key: key);

  @override
  State<EvaluationHistoryView> createState() => _EvaluationHistoryViewState();
}

class _EvaluationHistoryViewState extends State<EvaluationHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = context.read<StartupProfileViewModel>();
      context.read<EvaluationViewModel>().loadHistory(profileVm.startupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<EvaluationViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trung tâm Phân tích AI',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildLiveProcessingBanner(viewModel),
          Expanded(
            child: viewModel.isLoading && viewModel.history.isEmpty
                ? const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent))
                : _buildHistoryList(viewModel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EvaluationSubmissionView()),
          );
        },
        backgroundColor: StartupOnboardingTheme.goldAccent,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plusCircle),
        label: Text(
          'Đánh giá mới',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLiveProcessingBanner(EvaluationViewModel viewModel) {
    final processingItems = viewModel.history.where((e) => 
      e.status == EvaluationStatus.processing || e.status == EvaluationStatus.queued
    ).toList();

    if (processingItems.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              StartupOnboardingTheme.goldAccent.withOpacity(isDark ? 0.2 : 0.1),
              StartupOnboardingTheme.goldAccent.withOpacity(isDark ? 0.05 : 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: StartupOnboardingTheme.goldAccent,
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
                      color: StartupOnboardingTheme.goldAccent,
                    ),
                  ),
                  Text(
                    'Bạn có thể tiếp tục sử dụng ứng dụng, chúng tôi sẽ thông báo khi hoàn tất.',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
            Icon(LucideIcons.barChart2, size: 64, color: Theme.of(context).disabledColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử đánh giá',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
              ? StartupOnboardingTheme.goldAccent.withOpacity(0.3) 
              : theme.dividerColor,
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
                'Lần chạy #${item.runId}',
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
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            if (isCompleted && item.overallScore != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 16, color: StartupOnboardingTheme.goldAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Điểm tổng quát: ',
                    style: GoogleFonts.workSans(color: theme.textTheme.bodyLarge?.color),
                  ),
                  Text(
                    '${item.overallScore!.toStringAsFixed(1)}/10',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: StartupOnboardingTheme.goldAccent,
                    ),
                  ),
                ],
              ),
            ],
            if (item.status == EvaluationStatus.failed) ...[
              const SizedBox(height: 8),
              Text(
                'Lỗi: ${item.failureReason ?? "Không chi tiết"}',
                style: GoogleFonts.workSans(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ],
        ),
        trailing: isCompleted 
            ? const Icon(LucideIcons.chevronRight, color: StartupOnboardingTheme.goldAccent)
            : null,
      ),
    );
  }

  Widget _buildStatusBadge(EvaluationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withOpacity(0.5)),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.workSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
