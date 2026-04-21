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
          centerTitle: false,
          title: Text(
            'Tư vấn',
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
                const SizedBox(height: 12),
                _buildSubFilters(context, viewModel),
                Expanded(
                  child: viewModel.isLoading && viewModel.mentorships.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: [
                            _buildMentorshipList(
                              context,
                              _filterRequests(viewModel.mentorships, viewModel.selectedRequestFilter),
                              'Không có yêu cầu nào phù hợp',
                              viewModel,
                            ),
                            _buildMentorshipList(
                              context,
                              _filterSessions(viewModel.mentorships, viewModel.selectedSessionFilter),
                              'Không có phiên hướng dẫn nào',
                              viewModel,
                            ),
                            _buildMentorshipList(
                              context,
                              _filterReports(viewModel.mentorships, viewModel.selectedReportFilter),
                              'Chưa có báo cáo hoặc đánh giá nào',
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
                      'Thời hạn: ${viewModel.expiryDate}',
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clipboardList, size: 16),
                SizedBox(width: 8),
                Text('Yêu cầu của tôi'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.users, size: 16),
                SizedBox(width: 8),
                Text('Các phiên hướng dẫn'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.filePieChart, size: 16),
                SizedBox(width: 8),
                Text('Báo cáo & Đánh giá'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubFilters(BuildContext context, ConsultingViewModel viewModel) {
    final tabController = DefaultTabController.of(context);
    List<String> currentFilters;
    String selectedFilter;
    Function(String) onFilterSelected;

    switch (tabController.index) {
      case 0:
        currentFilters = ['Tất cả', 'Chờ phản hồi', 'Đã chấp nhận', 'Đã lên lịch', 'Hoàn thành', 'Từ chối', 'Đã hủy'];
        selectedFilter = viewModel.selectedRequestFilter;
        onFilterSelected = viewModel.setSelectedRequestFilter;
        break;
      case 1:
        currentFilters = ['Tất cả', 'Chờ xác nhận', 'Cố vấn đề xuất lịch', 'Sắp tới', 'Đang diễn ra', 'Đã hoàn thành', 'Đã hủy'];
        selectedFilter = viewModel.selectedSessionFilter;
        onFilterSelected = viewModel.setSelectedSessionFilter;
        break;
      case 2:
        currentFilters = ['Tất cả', 'Chờ đánh giá', 'Đã hoàn tất'];
        selectedFilter = viewModel.selectedReportFilter;
        onFilterSelected = viewModel.setSelectedReportFilter;
        break;
      default:
        currentFilters = [];
        selectedFilter = '';
        onFilterSelected = (_) {};
    }

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        // Recalculate based on real index
        switch (tabController.index) {
          case 0:
            currentFilters = ['Tất cả', 'Chờ phản hồi', 'Đã chấp nhận', 'Đã lên lịch', 'Hoàn thành', 'Từ chối', 'Đã hủy'];
            selectedFilter = viewModel.selectedRequestFilter;
            onFilterSelected = viewModel.setSelectedRequestFilter;
            break;
          case 1:
            currentFilters = ['Tất cả', 'Chờ xác nhận', 'Cố vấn đề xuất lịch', 'Sắp tới', 'Đang diễn ra', 'Đã hoàn thành', 'Đã hủy'];
            selectedFilter = viewModel.selectedSessionFilter;
            onFilterSelected = viewModel.setSelectedSessionFilter;
            break;
          case 2:
            currentFilters = ['Tất cả', 'Chờ đánh giá', 'Đã hoàn tất'];
            selectedFilter = viewModel.selectedReportFilter;
            onFilterSelected = viewModel.setSelectedReportFilter;
            break;
        }

        return Container(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            itemCount: currentFilters.length,
            itemBuilder: (context, index) {
              final filter = currentFilters[index];
              final isSelected = filter == selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onFilterSelected(filter);
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.03),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                  showCheckmark: false,
                  elevation: isSelected ? 2 : 0,
                  pressElevation: 4,
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<MentorshipDto> _filterRequests(List<MentorshipDto> mentorships, String filter) {
    if (filter == 'Tất cả') return mentorships;
    switch (filter) {
      case 'Chờ phản hồi': return mentorships.where((m) => m.status == MentorshipStatus.requested).toList();
      case 'Đã chấp nhận': return mentorships.where((m) => m.status == MentorshipStatus.accepted).toList();
      case 'Đã lên lịch': return mentorships.where((m) => m.status == MentorshipStatus.accepted && m.sessions.isNotEmpty).toList();
      case 'Hoàn thành': return mentorships.where((m) => m.status == MentorshipStatus.completed).toList();
      case 'Từ chối': return mentorships.where((m) => m.status == MentorshipStatus.rejected).toList();
      case 'Đã hủy': return mentorships.where((m) => m.status == MentorshipStatus.cancelled).toList();
      default: return mentorships;
    }
  }

  List<MentorshipDto> _filterSessions(List<MentorshipDto> mentorships, String filter) {
    // Session filtering logic
    if (filter == 'Tất cả') {
      return mentorships.where((m) => m.sessions.isNotEmpty || m.status == MentorshipStatus.inProgress || m.status == MentorshipStatus.accepted).toList();
    }
    switch (filter) {
      case 'Chờ xác nhận': 
        return mentorships.where((m) => m.status == MentorshipStatus.requested).toList();
      case 'Cố vấn đề xuất lịch':
        // logic for proposed slots but not yet confirmed session
        return mentorships.where((m) => m.status == MentorshipStatus.accepted && m.sessions.isEmpty).toList();
      case 'Sắp tới':
        return mentorships.where((m) => m.sessions.any((s) => s.scheduledStartAt.isAfter(DateTime.now()))).toList();
      case 'Đang diễn ra':
        return mentorships.where((m) => m.status == MentorshipStatus.inProgress).toList();
      case 'Đã hoàn thành':
        return mentorships.where((m) => m.status == MentorshipStatus.completed).toList();
      case 'Đã hủy':
        return mentorships.where((m) => m.status == MentorshipStatus.cancelled).toList();
      default:
        return mentorships;
    }
  }

  List<MentorshipDto> _filterReports(List<MentorshipDto> mentorships, String filter) {
    final completed = mentorships.where((m) => m.status == MentorshipStatus.completed).toList();
    if (filter == 'Tất cả') return completed;
    switch (filter) {
      case 'Chờ đánh giá':
        // Assume if mentorship is completed but feedback is missing
        return completed.where((m) => m.reports.isEmpty).toList(); // Simple heuristic: no report = not fully documented/feedbacked?
      case 'Đã hoàn tất':
        return completed.where((m) => m.reports.isNotEmpty).toList();
      default:
        return completed;
    }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        // Border removed for ultra-clean look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.03),
            blurRadius: 25,
            offset: const Offset(0, 10),
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
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30, // Larger premium avatar
                        backgroundColor: theme.primaryColor.withOpacity(0.05),
                        backgroundImage: item.advisorAvatar != null 
                          ? NetworkImage(item.advisorAvatar!) 
                          : null,
                        child: item.advisorAvatar == null 
                          ? Icon(LucideIcons.user, color: theme.primaryColor.withOpacity(0.4), size: 30) 
                          : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.advisorName ?? 'Cố vấn',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800, 
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mục tiêu: ${item.challengeDescription ?? "Không có mô tả"}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              height: 1.5,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Removed Divider and replaced spacing/divider with clean layout
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.calendar, size: 14, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày yêu cầu',
                          style: GoogleFonts.workSans(
                            fontSize: 10,
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
                          ),
                        ),
                        Text(
                          dateFormat.format(item.createdAt),
                          style: GoogleFonts.workSans(
                            fontSize: 13, 
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                          ),
                        ),
                      ],
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
        color = Colors.blue; text = 'Chờ phản hồi'; break;
      case MentorshipStatus.accepted:
        color = Colors.green; text = 'Chấp nhận'; break;
      case MentorshipStatus.inProgress:
        color = Colors.orange; text = 'Đang tư vấn'; break;
      case MentorshipStatus.completed:
        color = Colors.teal; text = 'Hoàn thành'; break;
      case MentorshipStatus.cancelled:
      case MentorshipStatus.rejected:
        color = Colors.red; text = 'Đã hủy'; break;
      default:
        color = Colors.grey; text = 'N/A';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
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
