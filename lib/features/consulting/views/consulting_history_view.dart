import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/status_badge.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/consulting_request_detail_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConsultingHistoryView extends StatelessWidget {
  const ConsultingHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử tư vấn',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: Consumer<ConsultingViewModel>(
        builder: (context, viewModel, child) {
          final history = viewModel.sessions
              .where((s) => s.status == ConsultingStatus.completed || s.status == ConsultingStatus.conducted || s.status == ConsultingStatus.cancelled)
              .toList();

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.history, size: 64, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch sử tư vấn.',
                    style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final session = history[index];
              return _buildHistoryCard(context, session);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ConsultingSessionModel session) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConsultingRequestDetailView(session: session)),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(session.advisor?.avatarUrl ?? ''),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.objective,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
                      ),
                      Text(
                        'Ngày: ${session.completedAt != null ? dateFormat.format(session.completedAt!) : dateFormat.format(session.requestedAt)}',
                        style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: session.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
