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
    'Tất cả',
    'Fintech',
    'AI & Data',
    'Fundraising',
    'Marketing',
    'SaaS',
    'Tài chính',
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
    final hasFilter = viewModel.selectedExpertise != 'Tất cả';
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
        child: Icon(
          LucideIcons.sliders,
          size: 18,
          color: hasFilter ? Colors.white : (isDark ? Colors.white70 : StartupOnboardingTheme.navyBg.withOpacity(0.6)),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ConsultingViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
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
            const SizedBox(height: 24),
            Text(
              'Lọc theo Lĩnh vực',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _expertises.length,
                itemBuilder: (context, index) {
                  final expertise = _expertises[index];
                  final isSelected = viewModel.selectedExpertise == expertise;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        viewModel.setSelectedExpertise(expertise);
                        Navigator.pop(context);
                      },
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
                            Text(
                              expertise,
                              style: GoogleFonts.workSans(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Theme.of(context).primaryColor : null,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(LucideIcons.check, color: Theme.of(context).primaryColor, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
