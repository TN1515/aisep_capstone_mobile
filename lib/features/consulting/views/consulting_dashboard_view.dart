import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/consulting_session_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/status_badge.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_discovery_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/consulting_request_detail_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConsultingDashboardView extends StatelessWidget {
  const ConsultingDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: StartupOnboardingTheme.navyBg,
          elevation: 0,
          title: Text(
            'Quản lý Tư vấn',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdvisorDiscoveryView()),
                  );
                },
                icon: const Icon(LucideIcons.search, size: 16),
                label: Text('Tìm Cố vấn', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StartupOnboardingTheme.goldAccent,
                  foregroundColor: StartupOnboardingTheme.navyBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  elevation: 0,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: StartupOnboardingTheme.goldAccent,
            labelColor: StartupOnboardingTheme.goldAccent,
            unselectedLabelColor: StartupOnboardingTheme.softIvory.withOpacity(0.4),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Yêu cầu'),
              Tab(text: 'Sắp tới'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: Consumer<ConsultingViewModel>(
          builder: (context, viewModel, child) {
            final sessions = viewModel.sessions;
            
            return TabBarView(
              children: [
                _buildSessionList(
                  sessions.where((s) => s.status == ConsultingStatus.requested || s.status == ConsultingStatus.proposed).toList(),
                  'Chưa có yêu cầu tư vấn nào.',
                ),
                _buildSessionList(
                  sessions.where((s) => s.status == ConsultingStatus.confirmed || s.status == ConsultingStatus.payable || s.status == ConsultingStatus.paid).toList(),
                  'Không có lịch hẹn sắp tới.',
                ),
                _buildSessionList(
                  sessions.where((s) => s.status == ConsultingStatus.conducted || s.status == ConsultingStatus.completed || s.status == ConsultingStatus.cancelled).toList(),
                  'Lịch sử tư vấn trống.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionList(List<ConsultingSessionModel> sessions, String emptyMsg) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendar, size: 64, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(context, session);
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, ConsultingSessionModel session) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

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
              MaterialPageRoute(
                builder: (_) => ConsultingRequestDetailView(session: session),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(session.advisor?.avatarUrl ?? ''),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.advisor?.name ?? 'Unknown Advisor',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: StartupOnboardingTheme.softIvory,
                            ),
                          ),
                          Text(
                            session.objective,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: session.status),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: StartupOnboardingTheme.goldAccent.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text(
                          session.scheduledAt != null ? dateFormat.format(session.scheduledAt!) : 'Chưa xếp lịch',
                          style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory),
                        ),
                      ],
                    ),
                    if (session.status == ConsultingStatus.completed && session.feedbackRating == null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: StartupOnboardingTheme.goldAccent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Gửi đánh giá',
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.navyBg),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: StartupOnboardingTheme.goldAccent.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text(
                            session.scheduledAt != null ? timeFormat.format(session.scheduledAt!) : '--:--',
                            style: GoogleFonts.workSans(fontSize: 12, color: StartupOnboardingTheme.softIvory),
                          ),
                        ],
                      ),
                    Icon(LucideIcons.chevronRight, size: 16, color: StartupOnboardingTheme.softIvory.withOpacity(0.2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
