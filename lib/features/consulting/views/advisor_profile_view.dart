import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/create_consulting_request_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AdvisorProfileView extends StatelessWidget {
  final AdvisorModel advisor;

  const AdvisorProfileView({Key? key, required this.advisor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context, isDark),
              _buildSliverStats(context),
              _buildSliverTabBar(context, isDark),
            ];
          },
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildAboutTab(context),
              _buildExpertiseTab(context),
              _buildAvailabilityTab(context),
              _buildReviewsTab(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCTA(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        _buildBookmarkAction(context, isDark),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Pattern/Gradient
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [StartupOnboardingTheme.navyBg, Colors.indigo.shade900.withOpacity(0.5)]
                    : [StartupOnboardingTheme.goldLight.withOpacity(0.4), Theme.of(context).scaffoldBackgroundColor],
                ),
              ),
            ),
            // Decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Profile Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                _buildProfileAvatar(context),
                const SizedBox(height: 20),
                Text(
                  advisor.fullName,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    advisor.title,
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Hero(
      tag: 'advisor_${advisor.id}',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          radius: 64,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(advisor.profilePhotoURL),
        ),
      ),
    );
  }

  Widget _buildBookmarkAction(BuildContext context, bool isDark) {
    return Consumer<ConsultingViewModel>(
      builder: (context, viewModel, child) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            advisor.isBookmarked ? Icons.favorite : LucideIcons.heart,
            color: advisor.isBookmarked ? Colors.redAccent : (isDark ? Colors.white : Colors.black),
            size: 20,
          ),
          onPressed: () {
            viewModel.toggleBookmark(advisor.id);
          },
        ),
      ),
    );
  }

  Widget _buildSliverStats(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatDetail(context, LucideIcons.star, advisor.averageRating.toStringAsFixed(1), 'Đánh giá (${advisor.reviewCount})', color: Colors.amber),
              _buildStatDetail(context, LucideIcons.users, advisor.completedSessions.toString(), 'Học viên'),
              _buildStatDetail(context, LucideIcons.briefcase, '${advisor.yearsOfExperience}y', 'Kinh nghiệm'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDetail(BuildContext context, IconData icon, String value, String label, {Color? color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 18),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSliverTabBar(BuildContext context, bool isDark) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Thông tin'),
              Tab(text: 'Lĩnh vực'),
              Tab(text: 'Lịch trống'),
              Tab(text: 'Đánh giá'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    List<dynamic> experiences = [];
    if (advisor.experiencesJson != null && advisor.experiencesJson!.isNotEmpty) {
      try {
        experiences = jsonDecode(advisor.experiencesJson!);
      } catch (e) {
        debugPrint('Error parsing experiences: $e');
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(context, 'Giới thiệu bản thân', advisor.bio),
          if (advisor.mentorshipPhilosophy != null && advisor.mentorshipPhilosophy!.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildInfoSection(context, 'Triết lý cố vấn', advisor.mentorshipPhilosophy!),
          ],
          const SizedBox(height: 32),
          _buildInfoSection(context, 'Kinh nghiệm làm việc', ''),
          const SizedBox(height: 12),
          if (experiences.isEmpty)
            _buildEmptyState(context, 'Chưa cập nhật kinh nghiệm')
          else
            ...experiences.map((exp) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.building2, size: 20, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp['position'] ?? 'Chuyên gia',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          exp['company'] ?? 'Công ty',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildExpertiseTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lĩnh vực chuyên môn',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: advisor.expertise.map((e) => _buildChip(context, e, LucideIcons.checkCircle2)).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Kỹ năng',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: advisor.skills.map((s) => _buildChip(context, s, LucideIcons.zap)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.workSans(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityTab(BuildContext context) {
    final ava = advisor.availability;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ava != null) ...[
            _buildAvailabilityRow(context, LucideIcons.video, 'Hình thức', ava['sessionFormats'] ?? 'Video Call'),
            _buildAvailabilityRow(context, LucideIcons.clock, 'Thời lượng chuẩn', '${ava['typicalSessionDuration'] ?? 60} phút'),
            _buildAvailabilityRow(
              context, 
              LucideIcons.users, 
              'Trạng thái', 
              (ava['isAcceptingNewMentees'] ?? true) ? 'Đang nhận Startup' : 'Đang bận'
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
          ],
          Text(
            'Lịch trống đề xuất',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildAvailabilityDay(context, 'Thứ Hai', '09:00 - 11:00, 14:00 - 17:00'),
          _buildAvailabilityDay(context, 'Thứ Tư', '10:00 - 12:00, 15:00 - 18:00'),
          _buildAvailabilityDay(context, 'Thứ Sáu', '09:00 - 11:30'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lịch trên chỉ mang tính chất tham khảo. Bạn có thể đề xuất khung giờ khác trong đơn đăng ký.',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.workSans(
              fontSize: 14, 
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityDay(BuildContext context, String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: GoogleFonts.workSans(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            time,
            style: GoogleFonts.workSans(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildRatingSummary(context),
          const SizedBox(height: 32),
          _buildEmptyState(context, 'Chưa có đánh giá chi tiết'),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Column(
          children: [
            Text(
              advisor.averageRating.toStringAsFixed(1),
              style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800),
            ),
            Row(
              children: List.generate(5, (index) => Icon(
                Icons.star, 
                size: 16, 
                color: index < advisor.averageRating ? Colors.amber : Colors.grey.shade300
              )),
            ),
            const SizedBox(height: 8),
            Text(
              '${advisor.reviewCount} đánh giá',
              style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              final count = advisor.ratingDistribution[star] ?? 0;
              final total = advisor.ratingDistribution.values.fold(0, (a, b) => a + b);
              final progress = total > 0 ? count / total : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(star.toString(), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : StartupOnboardingTheme.navyBg.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.workSans(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.layers, size: 40, color: Theme.of(context).dividerColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.workSans(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyFormat.format(advisor.hourlyRate),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'trọn gói / buổi',
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateConsultingRequestView(advisor: advisor),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Đặt lịch cố vấn',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
