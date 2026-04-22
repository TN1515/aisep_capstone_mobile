import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/models/advisor_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/create_consulting_request_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:aisep_capstone_mobile/core/utils/ui_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AdvisorProfileView extends StatefulWidget {
  final AdvisorModel advisor;

  const AdvisorProfileView({Key? key, required this.advisor}) : super(key: key);

  @override
  State<AdvisorProfileView> createState() => _AdvisorProfileViewState();
}

class _AdvisorProfileViewState extends State<AdvisorProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultingViewModel>().fetchAdvisorDetail(widget.advisor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultingViewModel>(
      builder: (context, viewModel, child) {
        // Use the fetched detail if available, otherwise fallback to the passed advisor
        final advisor = (viewModel.selectedAdvisorDetail != null && viewModel.selectedAdvisorDetail!.id == widget.advisor.id)
            ? viewModel.selectedAdvisorDetail!
            : widget.advisor;
            
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildSliverAppBar(context, advisor, isDark),
                  _buildSliverStats(context, advisor),
                  _buildSliverTabBar(context, isDark),
                ];
              },
              body: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildAboutTab(context, advisor),
                  _buildExpertiseTab(context, advisor),
                  _buildAvailabilityTab(context, advisor),
                  _buildReviewsTab(context, advisor, viewModel),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomCTA(context, advisor),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AdvisorModel advisor, bool isDark) {
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
        _buildBookmarkAction(context, advisor, isDark),
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
                _buildProfileAvatar(context, advisor),
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

  Widget _buildProfileAvatar(BuildContext context, AdvisorModel advisor) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: GestureDetector(
            onTap: () => UIUtils.showImagePreview(context, imageUrl: advisor.profilePhotoURL, tag: 'advisor_avatar_${advisor.id}'),
            child: Hero(
              tag: 'advisor_avatar_${advisor.id}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: NetworkImage(advisor.profilePhotoURL),
              ),
            ),
          ),
        ),
        if (advisor.isVerified)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.verified, 
                color: Colors.blue.shade600, 
                size: 28,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBookmarkAction(BuildContext context, AdvisorModel advisor, bool isDark) {
    return Consumer<ConsultingViewModel>(
      builder: (context, viewModel, child) {
        // Find the advisor in the live list to get reactive bookmark status
        final currentAdvisor = viewModel.advisors.firstWhere(
          (a) => a.id == advisor.id,
          orElse: () => advisor,
        );
        final isBookmarked = currentAdvisor.isBookmarked;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isBookmarked ? Icons.favorite : LucideIcons.heart,
              color: isBookmarked ? Colors.redAccent : (isDark ? Colors.white : Colors.black),
              size: 20,
            ),
            onPressed: () {
              viewModel.toggleBookmark(advisor.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildSliverStats(BuildContext context, AdvisorModel advisor) {
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
              Tab(text: 'Lịch rảnh'),
              Tab(text: 'Đánh giá'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, AdvisorModel advisor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSectionTitle(context, 'Giới thiệu chuyên gia'),
          const SizedBox(height: 12),
          Text(
            advisor.bio.isEmpty ? 'Chưa có thông tin giới thiệu.' : advisor.bio,
            style: GoogleFonts.workSans(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          
          if (advisor.mentorshipPhilosophy != null && advisor.mentorshipPhilosophy!.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildPhilosophyCard(context, advisor.mentorshipPhilosophy!),
          ],

          const SizedBox(height: 32),
          _buildPricingCard(context, advisor),
        ],
      ),
    );
  }

  Widget _buildInfoSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildPhilosophyCard(BuildContext context, String philosophy) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.05 : 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.quote, color: Theme.of(context).primaryColor.withOpacity(0.3), size: 24),
              const SizedBox(width: 12),
              Text(
                'TRIẾT LÝ HƯỚNG DẪN',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$philosophy"',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, AdvisorModel advisor) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    
    final price30 = advisor.hourlyRate * 0.5;
    final price120 = advisor.hourlyRate * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSectionTitle(context, 'Chi phí tư vấn'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _buildPricingRow(context, '30 phút', currencyFormat.format(price30)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildPricingRow(context, '120 phút', currencyFormat.format(price120), isHighlight: true),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.info, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thanh toán sau khi lịch hẹn được xác nhận.',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow(BuildContext context, String duration, String price, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          duration,
          style: GoogleFonts.workSans(
            fontSize: 15,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          price,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isHighlight ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseTab(BuildContext context, AdvisorModel advisor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSectionTitle(context, 'Lĩnh vực chuyên môn'),
          const SizedBox(height: 16),
          if (advisor.expertise.isEmpty)
            _buildEmptyState(context, 'Chưa cập nhật lĩnh vực')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: advisor.expertise.map<Widget>((e) => _buildChip(context, UIUtils.formatExpertiseLabel(e), LucideIcons.briefcase, color: Theme.of(context).primaryColor)).toList(),
            ),
          const SizedBox(height: 32),
          _buildInfoSectionTitle(context, 'Chuyên môn chính'),
          const SizedBox(height: 16),
          if (advisor.skills.isEmpty)
            _buildEmptyState(context, 'Chưa cập nhật chuyên môn')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: advisor.skills.map<Widget>((s) => _buildChip(context, UIUtils.formatExpertiseLabel(s), LucideIcons.zap, color: Colors.blue)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon, {Color? color}) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: themeColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.workSans(
              color: themeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAvailabilityTab(BuildContext context, AdvisorModel advisor) {
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
            'Lịch rảnh trong tuần',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (ava == null || ava['weeklyAvailability'] == null)
            _buildEmptyState(context, 'Chưa thiết lập lịch rảnh cụ thể')
          else ...[
            ... (ava['weeklyAvailability'] as Map).entries.map((entry) => _buildAvailabilityDay(context, entry.key, entry.value)),
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

  Widget _buildReviewsTab(BuildContext context, AdvisorModel advisor, ConsultingViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildRatingSummary(context, advisor),
          const SizedBox(height: 32),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (advisor.reviews.isEmpty)
            _buildEmptyState(context, 'Chưa có đánh giá chi tiết')
          else
            ...advisor.reviews.map((f) => _buildFeedbackCard(context, f)),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, dynamic review) {
    // Map backend ReviewDto to UI
    final author = review['author'] ?? 'Người dùng AISEP';
    final rating = review['rating'] ?? 5;
    final comment = review['text'] ?? '';
    final submittedAtStr = review['submittedAt'] ?? '';
    
    DateTime? date;
    if (submittedAtStr.isNotEmpty) {
      date = DateTime.tryParse(submittedAtStr);
    }
    
    final dateDisplay = date != null ? DateFormat('dd/MM/yyyy').format(date) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    if (review['stage'] != null)
                      Text(
                        review['stage'],
                        style: GoogleFonts.workSans(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(5, (index) => Icon(
                      Icons.star, 
                      size: 14, 
                      color: index < rating ? Colors.amber : Colors.grey.shade300
                    )),
                  ),
                  if (dateDisplay.isNotEmpty)
                    Text(
                      dateDisplay,
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (comment.isNotEmpty)
            Text(
              comment,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            )
          else
            Text(
              'Người dùng không để lại nhận xét.',
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context, AdvisorModel advisor) {
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

  Widget _buildBottomCTA(BuildContext context, AdvisorModel advisor) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currencyFormat.format(advisor.hourlyRate),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: theme.primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ giờ',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: theme.primaryColor.withOpacity(0.4),
                ),
                child: Text(
                  'Đặt lịch cố vấn',
                  style: GoogleFonts.outfit(
                    fontSize: 17, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
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
