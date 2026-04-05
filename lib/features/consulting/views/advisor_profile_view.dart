import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/create_consulting_request_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AdvisorProfileView extends StatelessWidget {
  final AdvisorModel advisor;

  const AdvisorProfileView({Key? key, required this.advisor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context),
              _buildSliverStats(),
              _buildSliverTabBar(),
            ];
          },
          body: TabBarView(
            children: [
              _buildAboutTab(),
              _buildExpertiseTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCTA(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: StartupOnboardingTheme.navyBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<ConsultingViewModel>(
          builder: (context, viewModel, child) => IconButton(
            icon: Icon(
              advisor.isBookmarked ? Icons.favorite : LucideIcons.heart,
              color: advisor.isBookmarked ? Colors.redAccent : Colors.white,
            ),
            onPressed: () {
              viewModel.toggleBookmark(advisor.id);
              ToastUtils.showTopToast(
                context, 
                advisor.isBookmarked ? 'Đã gỡ khỏi danh sách theo dõi' : 'Đã thêm vào danh sách theo dõi'
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    StartupOnboardingTheme.navyBg,
                    StartupOnboardingTheme.goldAccent.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            // Profile Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Hero(
                  tag: 'advisor_${advisor.id}',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: StartupOnboardingTheme.goldAccent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(advisor.avatarUrl),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  advisor.name,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.softIvory,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advisor.title,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: StartupOnboardingTheme.goldAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: StartupOnboardingTheme.navySurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatDetail(LucideIcons.star, advisor.rating.toString(), 'Rating', color: Colors.orangeAccent),
              _buildStatDetail(LucideIcons.calendar, advisor.totalSessions.toString(), 'Sessions'),
              _buildStatDetail(LucideIcons.briefcase, '${advisor.yearsExperience}y', 'Exps'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDetail(IconData icon, String value, String label, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? StartupOnboardingTheme.goldAccent, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: StartupOnboardingTheme.softIvory.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          indicatorColor: StartupOnboardingTheme.goldAccent,
          labelColor: StartupOnboardingTheme.goldAccent,
          unselectedLabelColor: StartupOnboardingTheme.softIvory.withOpacity(0.4),
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Giới thiệu'),
            Tab(text: 'Chuyên môn'),
            Tab(text: 'Đánh giá'),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Tiểu sử', advisor.bio),
          const SizedBox(height: 24),
          _buildInfoSection('Chứng chỉ & Thành tựu', ''),
          const SizedBox(height: 8),
          ...advisor.certifications.map((cert) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(LucideIcons.checkCircle, size: 16, color: StartupOnboardingTheme.goldAccent),
                const SizedBox(width: 8),
                Text(cert, style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExpertiseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: advisor.expertise.map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.2)),
          ),
          child: Text(
            e,
            style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory, fontWeight: FontWeight.bold),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(LucideIcons.messageSquare, size: 48, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
        const SizedBox(height: 16),
        Text(
          'Chưa có đánh giá chi tiết.',
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: StartupOnboardingTheme.softIvory.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
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
          backgroundColor: StartupOnboardingTheme.goldAccent,
          foregroundColor: StartupOnboardingTheme.navyBg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'Gửi yêu cầu Tư vấn',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: StartupOnboardingTheme.navyBg,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
