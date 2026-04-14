import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../evaluation/view_models/evaluation_view_model.dart';
import '../../evaluation/models/evaluation_models.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class AiReportDetailView extends StatefulWidget {
  final String evaluationId;

  const AiReportDetailView({super.key, required this.evaluationId});

  @override
  State<AiReportDetailView> createState() => _AiReportDetailViewState();
}

class _AiReportDetailViewState extends State<AiReportDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.tryParse(widget.evaluationId) ?? 0;
      context.read<EvaluationViewModel>().loadReport(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Báo cáo phân tích AI'),
      ),
      body: Consumer<EvaluationViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildError(context, viewModel.errorMessage!);
          }

          final report = viewModel.currentReport;
          if (report == null) {
            return const Center(child: Text('Không tìm thấy dữ liệu báo cáo'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallScore(context, report.overallResult),
                const SizedBox(height: 32),
                _buildNarrativeSection(context, report.narrative),
                const SizedBox(height: 32),
                _buildCriteriaList(context, report.criteriaResults),
                const SizedBox(height: 40),
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  String _translateLevel(String level) {
    final mapping = {
      'excellent': 'Xuất sắc',
      'good': 'Tốt',
      'fair': 'Trung bình',
      'poor': 'Yếu',
      'high potential': 'Tiềm năng cao',
      'moderate potential': 'Tiềm năng vừa',
      'low potential': 'Tiềm năng thấp',
      'seed': 'Giai đoạn Seed',
      'early stage': 'Giai đoạn sớm',
    };
    String key = level.toLowerCase().trim();
    return mapping[key] ?? mapping[key.replaceAll('_', ' ')] ?? level;
  }

  Widget _buildOverallScore(BuildContext context, OverallResult result) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Điểm tiềm năng đầu tư',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: result.score / 100,
                  strokeWidth: 12,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  color: theme.primaryColor,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${result.score}',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Mức độ: ${_translateLevel(result.potentialLevel)}',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Độ tin cậy của AI: ${(result.confidence * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrativeSection(BuildContext context, Narrative narrative) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNarrativeItem(
          context, 
          'Điểm mạnh vượt trội', 
          narrative.topStrengths, 
          LucideIcons.trendingUp, 
          Colors.green
        ),
        const SizedBox(height: 24),
        _buildNarrativeItem(
          context, 
          'Rủi ro cần lưu ý', 
          narrative.topConcerns, 
          LucideIcons.alertCircle, 
          Colors.orange
        ),
        const SizedBox(height: 24),
        _buildNarrativeItem(
          context, 
          'Lĩnh vực cần cải thiện', 
          narrative.recommendations, 
          LucideIcons.lightbulb, 
          Colors.blue
        ),
      ],
    );
  }

  Widget _buildNarrativeItem(BuildContext context, String title, List<String> items, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.workSans(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8), height: 1.5),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCriteriaList(BuildContext context, List<CriteriaResult> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết tiêu chí',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildCriteriaItem(context, item)),
      ],
    );
  }

  String _translateCriteria(String name) {
    final mapping = {
      'market_analysis': 'Phân tích thị trường',
      'solution_problem_fit': 'Giải pháp & Vấn đề',
      'business_model': 'Mô hình kinh doanh',
      'team_experience': 'Đội ngũ & Kinh nghiệm',
      'financial_projections': 'Dự báo tài chính',
      'competitive_landscape': 'Bối cảnh cạnh tranh',
      'execution_strategy': 'Chiến lược thực thi',
      'experience_quality': 'Chất lượng kinh nghiệm',
      'experience_quality_criterion': 'Chất lượng kinh nghiệm',
      'market_size_vibe': 'Quy mô thị trường',
      'solution_scalability': 'Khả năng mở rộng',
      'technical_feasibility': 'Khả thi kỹ thuật',
      'growth_potential': 'Tiềm năng tăng trưởng',
    };

    String key = name.toLowerCase().trim();
    // Xử lý các trường hợp key có khoảng trắng hoặc ký tự đặc biệt
    return mapping[key] ?? mapping[key.replaceAll(' ', '_')] ?? mapping[key.replaceAll('_', ' ')] ?? name;
  }

  Widget _buildCriteriaItem(BuildContext context, CriteriaResult item) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _translateCriteria(item.criteriaName),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.score}/100',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.explanation,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          if (item.evidenceLocations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.fileSearch, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Bằng chứng tìm thấy tại trang: ${item.evidenceLocations.join(", ")}',
                  style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Tải báo cáo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.share2),
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Không thể tải báo cáo',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final id = int.tryParse(widget.evaluationId) ?? 0;
                context.read<EvaluationViewModel>().loadReport(id);
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
