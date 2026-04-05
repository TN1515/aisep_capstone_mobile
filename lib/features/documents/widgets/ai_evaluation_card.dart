import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/ai_evaluation_model.dart';
import 'package:intl/intl.dart';

class AiEvaluationCard extends StatelessWidget {
  final AiEvaluationModel evaluation;
  final VoidCallback onTap;

  const AiEvaluationCard({
    super.key,
    required this.evaluation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              StartupOnboardingTheme.navySurface,
              StartupOnboardingTheme.navySurface.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildScoreIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evaluation.documentName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StartupOnboardingTheme.softIvory,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đã phân tích vào ${DateFormat('dd/MM/yyyy HH:mm').format(evaluation.evaluationDate)}',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, color: StartupOnboardingTheme.goldAccent.withOpacity(0.3)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              evaluation.summary,
              style: GoogleFonts.workSans(
                fontSize: 14,
                height: 1.5,
                color: StartupOnboardingTheme.softIvory.withOpacity(0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: evaluation.metrics.entries.take(3).map((e) => _buildMetricChip(e.key, e.value)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2), width: 4),
      ),
      child: Center(
        child: Text(
          evaluation.overallScore.toStringAsFixed(1),
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navyBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.goldAccent,
            ),
          ),
        ],
      ),
    );
  }
}
