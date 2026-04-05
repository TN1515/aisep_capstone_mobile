import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/advisor_card.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_profile_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/bookmarked_advisors_view.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AdvisorDiscoveryView extends StatefulWidget {
  const AdvisorDiscoveryView({Key? key}) : super(key: key);

  @override
  State<AdvisorDiscoveryView> createState() => _AdvisorDiscoveryViewState();
}

class _AdvisorDiscoveryViewState extends State<AdvisorDiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultingViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: StartupOnboardingTheme.navyBg,
            appBar: AppBar(
              backgroundColor: StartupOnboardingTheme.navyBg,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: StartupOnboardingTheme.softIvory),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Khám phá Cố vấn',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.softIvory,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookmarkedAdvisorsView()),
                    );
                  },
                  icon: const Icon(LucideIcons.heart, color: StartupOnboardingTheme.goldAccent),
                  tooltip: 'Danh sách theo dõi',
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                _buildSearchSection(viewModel),
                const SizedBox(height: 8),
                _buildAdvisorList(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(ConsultingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: StartupOnboardingTheme.navySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
                onChanged: viewModel.setSearchQuery,
                decoration: InputDecoration(
                  icon: const Icon(LucideIcons.search, size: 20, color: StartupOnboardingTheme.goldAccent),
                  hintText: 'Tên, chuyên môn, kinh nghiệm...',
                  hintStyle: GoogleFonts.workSans(
                    color: StartupOnboardingTheme.softIvory.withOpacity(0.2),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ConsultingViewModel viewModel) {
    final bool hasFilter = viewModel.selectedExpertise != 'Tất cả';
    
    return PopupMenuButton<String>(
      initialValue: viewModel.selectedExpertise,
      onSelected: viewModel.setSelectedExpertise,
      offset: const Offset(0, 50),
      color: StartupOnboardingTheme.navySurface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasFilter ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFilter ? StartupOnboardingTheme.goldAccent : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Icon(
          LucideIcons.sliders, 
          color: hasFilter ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.goldAccent, 
          size: 20,
        ),
      ),
      itemBuilder: (context) => [
        'Tất cả',
        'Fintech',
        'AI & Data',
        'Fundraising',
        'Marketing',
        'SaaS',
        'Tài chính',
      ].map((String choice) {
        return PopupMenuItem<String>(
          value: choice,
          child: Text(
            choice,
            style: GoogleFonts.workSans(
              color: viewModel.selectedExpertise == choice 
                  ? StartupOnboardingTheme.goldAccent 
                  : StartupOnboardingTheme.softIvory,
              fontWeight: viewModel.selectedExpertise == choice ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdvisorList(ConsultingViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent)),
      );
    }

    final filteredAdvisors = viewModel.advisors;

    if (filteredAdvisors.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.search, size: 64, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy Cố vấn phù hợp.',
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: filteredAdvisors.length,
        itemBuilder: (context, index) {
          final advisor = filteredAdvisors[index];
          return AdvisorCard(
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
          );
        },
      ),
    );
  }
}
