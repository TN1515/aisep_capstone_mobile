import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../view_models/evaluation_view_model.dart';
import '../models/evaluation_models.dart';
import '../../../core/theme/startup_onboarding_theme.dart';

class EvaluationReportView extends StatefulWidget {
  final int runId;
  const EvaluationReportView({Key? key, required this.runId}) : super(key: key);

  @override
  State<EvaluationReportView> createState() => _EvaluationReportViewState();
}

class _EvaluationReportViewState extends State<EvaluationReportView> {
  DocumentSourceType? _selectedSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvaluationViewModel>().loadReport(widget.runId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<EvaluationViewModel>();
    final report = viewModel.currentReport;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Báo cáo Phân tích AI',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.appBarTheme.titleTextStyle?.color,
              ),
            ),
            if (report != null)
              Text(
                _selectedSource == null ? 'Toàn bộ tài liệu' : _selectedSource!.label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: theme.primaryColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, color: StartupOnboardingTheme.goldAccent),
            onPressed: () {
              // Share logic placeholder
            },
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent))
          : report == null
              ? _buildErrorState(viewModel.errorMessage)
              : _buildReportContent(report),
    );
  }

  Widget _buildErrorState(String? error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Không thể tải báo cáo',
              style: GoogleFonts.outfit(fontSize: 20, color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Đã xảy ra lỗi không xác định',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_selectedSource == null) {
                  context.read<EvaluationViewModel>().loadReport(widget.runId);
                } else {
                  context.read<EvaluationViewModel>().loadSourceReport(widget.runId, _selectedSource!);
                }
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(EvaluationReportResult report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSourceSelector(),
          const SizedBox(height: 20),
          _buildScoreOverview(report.overallResult),
          const SizedBox(height: 24),
          _buildRecommendationStatus(),
          const SizedBox(height: 32),
          _buildSectionHeader('Phân loại Startup', LucideIcons.layers),
          const SizedBox(height: 16),
          _buildClassificationSection(report.classification),
          const SizedBox(height: 32),
          _buildSectionHeader('Phân tích chi tiết', LucideIcons.barChart),
          const SizedBox(height: 16),
          _buildCriteriaList(report.criteriaResults),
          const SizedBox(height: 32),
          _buildSectionHeader('Đánh giá định tính', LucideIcons.fileText),
          const SizedBox(height: 16),
          _buildNarrativeSection(report.narrative),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          _buildSourceTab(null, 'Tổng hợp'),
          _buildSourceTab(DocumentSourceType.pitchDeck, 'Pitch Deck'),
          _buildSourceTab(DocumentSourceType.businessPlan, 'Business Plan'),
        ],
      ),
    );
  }

  Widget _buildSourceTab(DocumentSourceType? type, String label) {
    final isSelected = _selectedSource == type;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isSelected) return;
          setState(() => _selectedSource = type);
          if (type == null) {
            context.read<EvaluationViewModel>().loadReport(widget.runId);
          } else {
            context.read<EvaluationViewModel>().loadSourceReport(widget.runId, type);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? StartupOnboardingTheme.goldAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationStatus() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.info, size: 16, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Điểm số này đã được AI cập nhật vào hệ thống đề xuất cho Nhà đầu tư.',
                style: GoogleFonts.workSans(fontSize: 11, color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationSection(Classification classification) {
    final theme = Theme.of(context);
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildClassificationRow('Lĩnh vực', classification.industry, LucideIcons.briefcase),
            const Divider(height: 24),
            _buildClassificationRow('Giai đoạn', classification.stage, LucideIcons.trendingUp),
            const Divider(height: 24),
            _buildClassificationRow(
              'Mô hình', 
              classification.businessModel.join(' • '), 
              LucideIcons.component
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: StartupOnboardingTheme.goldAccent),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreOverview(OverallResult overall) {
    final theme = Theme.of(context);
    return FadeIn(
      duration: const Duration(seconds: 1),
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: overall.score / 100,
                    strokeWidth: 12,
                    backgroundColor: theme.dividerColor,
                    color: StartupOnboardingTheme.goldAccent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${overall.score.toInt()}',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: StartupOnboardingTheme.goldAccent,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.3)),
              ),
              child: Text(
                overall.potentialLevel.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: StartupOnboardingTheme.goldAccent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Độ tin cậy của AI: ${(overall.confidence * 100).toInt()}%',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: StartupOnboardingTheme.goldAccent),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaList(List<CriteriaResult> criteria) {
    final theme = Theme.of(context);
    return Column(
      children: criteria.asMap().entries.map((entry) {
        final index = entry.key;
        final c = entry.value;
        return FadeInLeft(
          delay: Duration(milliseconds: 100 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.criteriaName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      '${c.score.toInt()}/100',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: StartupOnboardingTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: c.score / 100,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor,
                    color: StartupOnboardingTheme.goldAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  c.explanation,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNarrativeSection(Narrative narrative) {
    return Column(
      children: [
        _buildNarrativeCard(
          'Điểm mạnh nổi bật', 
          narrative.topStrengths, 
          LucideIcons.checkCircle, 
          Colors.greenAccent
        ),
        const SizedBox(height: 16),
        _buildNarrativeCard(
          'Rủi ro & Thách thức', 
          narrative.topConcerns, 
          LucideIcons.alertCircle, 
          Colors.orangeAccent
        ),
        const SizedBox(height: 16),
        _buildNarrativeCard(
          'Đề xuất cải thiện', 
          narrative.recommendations, 
          LucideIcons.lightbulb, 
          StartupOnboardingTheme.goldAccent
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tóm lược điều hành',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.goldAccent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                narrative.summary,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrativeCard(String title, List<String> items, IconData icon, Color accentColor) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.zero,
          leading: Icon(icon, color: accentColor),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          children: items.map((item) => Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: accentColor, fontSize: 18)),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
