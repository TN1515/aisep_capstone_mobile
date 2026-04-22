import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/advisor_card.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_profile_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/bookmarked_advisors_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AdvisorDiscoveryView extends StatefulWidget {
  const AdvisorDiscoveryView({Key? key}) : super(key: key);

  @override
  State<AdvisorDiscoveryView> createState() => _AdvisorDiscoveryViewState();
}

class _AdvisorDiscoveryViewState extends State<AdvisorDiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _expertises = [
    'Tất cả chuyên môn',
    'Product Strategy',
    'Fundraising',
    'Engineering',
    'AI/ML',
    'Growth Hacking',
    'Marketing',
    'Legal & Compliance',
    'Operations',
    'SaaS',
    'FinTech',
    'E-commerce',
    'Nhân sự & Đội ngũ',
    'Tài chính',
  ];

  final List<String> _experiences = [
    'Tất cả kinh nghiệm',
    '1–3 năm',
    '3–7 năm',
    '7+ năm',
    '10+ năm',
  ];

  final List<String> _ratings = [
    'Tất cả xếp hạng',
    '4.5★ trở lên',
    '4★ trở lên',
    '3★ trở lên',
  ];

  final List<String> _sorts = [
    'Phù hợp nhất',
    'Đánh giá cao nhất',
    'Nhiều kinh nghiệm nhất',
    'Nhiều phiên nhất',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ConsultingViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black87),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    'Khám phá Cố vấn',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  actions: [
                    _buildBookmarkAction(context),
                    const SizedBox(width: 16),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(viewModel, isDark),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterButton(context, viewModel, isDark),
                      ],
                    ),
                  ),
                ),
                if (viewModel.isLoading && viewModel.advisors.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (viewModel.errorMessage != null)
                  SliverFillRemaining(
                    child: _buildErrorView(viewModel),
                  )
                else if (viewModel.advisors.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyView(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final advisor = viewModel.advisors[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AdvisorCard(
                              advisor: advisor,
                              onBookmark: () => viewModel.toggleBookmark(advisor.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdvisorProfileView(advisor: advisor),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: viewModel.advisors.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(BuildContext context, ConsultingViewModel viewModel, bool isDark) {
    final hasFilter = viewModel.selectedExpertise != 'Tất cả chuyên môn' || 
                      viewModel.selectedExperience != 'Tất cả kinh nghiệm' ||
                      viewModel.selectedRating != 'Tất cả xếp hạng' ||
                      viewModel.selectedSort != 'Phù hợp nhất';
                      
    return GestureDetector(
      onTap: () => _showFilterSheet(context, viewModel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: hasFilter 
            ? Theme.of(context).primaryColor 
            : (isDark ? Colors.white.withOpacity(0.05) : StartupOnboardingTheme.navyBg.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFilter 
              ? Theme.of(context).primaryColor 
              : (isDark ? Colors.white.withOpacity(0.08) : StartupOnboardingTheme.navyBg.withOpacity(0.06)),
            width: 1,
          ),
          boxShadow: hasFilter ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              LucideIcons.sliders,
              size: 18,
              color: hasFilter ? Colors.white : (isDark ? Colors.white70 : StartupOnboardingTheme.navyBg.withOpacity(0.6)),
            ),
            if (hasFilter)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ConsultingViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DefaultTabController(
        length: 4,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Consumer<ConsultingViewModel>(
            builder: (context, vm, _) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.normal, fontSize: 14),
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(text: 'Chuyên môn'),
                    Tab(text: 'Kinh nghiệm'),
                    Tab(text: 'Xếp hạng'),
                    Tab(text: 'Sắp xếp'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFilterList(context, vm.selectedExpertise, _expertises, (val) => vm.setSelectedExpertise(val)),
                      _buildFilterList(context, vm.selectedExperience, _experiences, (val) => vm.setSelectedExperience(val)),
                      _buildFilterList(context, vm.selectedRating, _ratings, (val) => vm.setSelectedRating(val)),
                      _buildFilterList(context, vm.selectedSort, _sorts, (val) => vm.setSelectedSort(val)),
                    ],
                  ),
                ),
                _buildApplyButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterList(BuildContext context, String selectedValue, List<String> options, Function(String) onSelect) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final value = options[index];
        final isSelected = selectedValue == value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onSelect(value),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(LucideIcons.check, color: Theme.of(context).primaryColor, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'Áp dụng bộ lọc',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBookmarkAction(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookmarkedAdvisorsView()),
          );
        },
        icon: Icon(LucideIcons.heart, color: Theme.of(context).primaryColor, size: 18),
        tooltip: 'Theo dõi',
      ),
    );
  }

  Widget _buildSearchField(ConsultingViewModel viewModel, bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : StartupOnboardingTheme.navyBg.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : StartupOnboardingTheme.navyBg.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onChanged: viewModel.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, lĩnh vực...',
          hintStyle: GoogleFonts.workSans(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
            fontSize: 13,
          ),
          icon: Icon(LucideIcons.search, size: 18, color: Theme.of(context).primaryColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildErrorView(ConsultingViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.fetchAdvisors(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.ghost, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'Không tìm thấy cố vấn',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử thay đổi từ khóa hoặc bộ lọc.',
            style: GoogleFonts.workSans(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
