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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: const Text('Quản lý Tư vấn'),
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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  elevation: 0,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
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
                  context,
                  sessions.where((s) => s.status == ConsultingStatus.requested || s.status == ConsultingStatus.proposed).toList(),
                  'Chưa có yêu cầu tư vấn nào.',
                ),
                _buildSessionList(
                  context,
                  sessions.where((s) => s.status == ConsultingStatus.confirmed || s.status == ConsultingStatus.payable || s.status == ConsultingStatus.paid).toList(),
                  'Không có lịch hẹn sắp tới.',
                ),
                _buildSessionList(
                  context,
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

  Widget _buildSessionList(BuildContext context, List<ConsultingSessionModel> sessions, String emptyMsg) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendar, size: 64, color: Theme.of(context).dividerColor),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3)),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            session.objective,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: session.status),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Theme.of(context).dividerColor, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text(
                          session.scheduledAt != null ? dateFormat.format(session.scheduledAt!) : 'Chưa xếp lịch',
                          style: GoogleFonts.workSans(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                    if (session.status == ConsultingStatus.completed && session.feedbackRating == null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Gửi đánh giá',
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text(
                            session.scheduledAt != null ? timeFormat.format(session.scheduledAt!) : '--:--',
                            style: GoogleFonts.workSans(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    Icon(LucideIcons.chevronRight, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.2)),
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
