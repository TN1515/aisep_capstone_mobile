import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/ai_evaluation_model.dart';
import 'package:intl/intl.dart';

class AiReportDetailView extends StatelessWidget {
  final AiEvaluationModel evaluation;

  const AiReportDetailView({super.key, required this.evaluation});

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
        title: const Text('Báo cáo chi tiết AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSummarySection(context),
            const SizedBox(height: 32),
            _buildMetricsGrid(context),
            const SizedBox(height: 32),
            _buildSwotAnalysis(context),
            const SizedBox(height: 40),
            _buildDownloadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Text(
            'KẾT QUẢ ĐÁNH GIÁ',
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          evaluation.documentName,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ngày đánh giá: ${DateFormat('dd MMMM, yyyy').format(evaluation.evaluationDate)}',
          style: GoogleFonts.workSans(
            fontSize: 14,
            color: textColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tóm tắt chuyên sâu',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          evaluation.summary,
          style: GoogleFonts.workSans(
            fontSize: 15,
            height: 1.6,
            color: textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chỉ số tiềm năng',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: evaluation.metrics.length,
          itemBuilder: (context, index) {
            final entry = evaluation.metrics.entries.elementAt(index);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      color: textColor.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        entry.value.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ 10',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: textColor.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSwotAnalysis(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn(context, 'Điểm mạnh', evaluation.strengths, Colors.greenAccent)),
        const SizedBox(width: 16),
        Expanded(child: _buildColumn(context, 'Thách thức', evaluation.weaknesses, Colors.orangeAccent)),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, String title, List<String> items, Color color) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.dot, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang chuẩn bị bản PDF báo cáo...')),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.downloadCloud, color: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white),
            const SizedBox(width: 12),
            Text(
              'Tải báo cáo PDF',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
