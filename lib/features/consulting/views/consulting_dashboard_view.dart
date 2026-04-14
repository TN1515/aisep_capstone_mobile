import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/mentorship_models.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_discovery_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/mentorship_detail_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConsultingDashboardView extends StatefulWidget {
  const ConsultingDashboardView({Key? key}) : super(key: key);

  @override
  State<ConsultingDashboardView> createState() => _ConsultingDashboardViewState();
}

class _ConsultingDashboardViewState extends State<ConsultingDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultingViewModel>().fetchMentorships();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Lịch sử Cố vấn',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          actions: [
            _buildNewRequestButton(context),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<ConsultingViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildSubscriptionMeter(context, viewModel, isDark),
                _buildTabBar(context),
                Expanded(
                  child: viewModel.isLoading && viewModel.mentorships.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: [
                            _buildMentorshipList(
                              context,
                              viewModel.mentorships.where((m) => m.status == MentorshipStatus.requested).toList(),
                              'Chưa có yêu cầu nào',
                              viewModel,
                            ),
                            _buildMentorshipList(
                              context,
                              viewModel.mentorships.where((m) => 
                                m.status == MentorshipStatus.accepted || 
                                m.status == MentorshipStatus.inProgress
                              ).toList(),
                              'Không có lịch hẹn sắp tới',
                              viewModel,
                            ),
                            _buildMentorshipList(
                              context,
                              viewModel.mentorships.where((m) => 
                                m.status == MentorshipStatus.completed || 
                                m.status == MentorshipStatus.cancelled ||
                                m.status == MentorshipStatus.rejected
                              ).toList(),
                              'Lịch sử tư vấn trống',
                              viewModel,
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewRequestButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdvisorDiscoveryView()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: Text(
          'Đăng ký mới',
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSubscriptionMeter(BuildContext context, ConsultingViewModel viewModel, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [Colors.indigo.shade800, Colors.indigo.shade900]
              : [Colors.blue.shade600, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gói dịch vụ: ${viewModel.planName}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Thời hạn: 15/05/2026',
                      style: GoogleFonts.workSans(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Icon(LucideIcons.crown, color: Colors.amber.shade300, size: 28),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lượt yêu cầu cố vấn',
                  style: GoogleFonts.workSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${viewModel.usedRequests} / ${viewModel.maxRequests}',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: viewModel.subscriptionProgress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: 'Đang gửi'),
          Tab(text: 'Sắp tới'),
          Tab(text: 'Lịch sử'),
        ],
      ),
    );
  }

  Widget _buildMentorshipList(BuildContext context, List<MentorshipDto> items, String emptyMsg, ConsultingViewModel viewModel) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.calendarX, size: 48, color: Colors.grey.withOpacity(0.3)),
            ),
            const SizedBox(height: 16),
            Text(emptyMsg, style: GoogleFonts.workSans(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.fetchMentorships,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildMentorshipCard(context, items[index]);
        },
      ),
    );
  }

  Widget _buildMentorshipCard(BuildContext context, MentorshipDto item) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MentorshipDetailView(mentorship: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: item.advisorAvatar != null 
                        ? NetworkImage(item.advisorAvatar!) 
                        : null,
                      child: item.advisorAvatar == null ? const Icon(LucideIcons.user) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.advisorName ?? 'Advisor',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          Text(
                            item.challengeDescription ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(item.status),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 14, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(item.createdAt),
                      style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (item.status == MentorshipStatus.accepted)
                      _buildQuickAction(context, 'Thanh toán', Colors.green, LucideIcons.creditCard)
                    else if (item.status == MentorshipStatus.completed)
                      _buildQuickAction(context, 'Đánh giá', Colors.orange, LucideIcons.star),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MentorshipStatus status) {
    Color color;
    String text;

    switch (status) {
      case MentorshipStatus.requested:
        color = Colors.blue; text = 'Đang chờ'; break;
      case MentorshipStatus.accepted:
        color = Colors.green; text = 'Chấp nhận'; break;
      case MentorshipStatus.inProgress:
        color = Colors.orange; text = 'Đang tư vấn'; break;
      case MentorshipStatus.completed:
        color = Colors.grey; text = 'Hoàn thành'; break;
      case MentorshipStatus.cancelled:
      case MentorshipStatus.rejected:
        color = Colors.red; text = 'Đã hủy'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
