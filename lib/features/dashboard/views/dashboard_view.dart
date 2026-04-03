import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/models/dashboard_stats_model.dart';
import 'package:aisep_capstone_mobile/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/dashboard_header.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/summary_progress_card.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/ongoing_project_card.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/activity_item_tile.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/startup_bottom_nav_bar.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/features/profile/views/startup_profile_view.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_form_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;
  int _currentIndex = 2; // Default to Dashboard (Center)

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _viewModel.fetchDashboardData();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      // Integration: Bottom Navigation Bar is now directly in DashboardView
      bottomNavigationBar: StartupBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      // Integration: Floating Action Button in the Dashboard notch
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          onPressed: () => _onTabTapped(2), // Always go to Dashboard
          backgroundColor: _currentIndex == 2 ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(
            Icons.home_rounded,
            color: _currentIndex == 2 ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.goldAccent,
            size: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPlaceholder('Kết nối', Icons.people_alt_outlined),
          KycFormView(
            isIncorporated: true, 
            onBack: () => _onTabTapped(2), // Move back to Home (Index 2)
          ), 
          _buildDashboardContent(), // Center item
          _buildPlaceholder('Tài liệu', Icons.description_outlined),
          const StartupProfileView(),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading && _viewModel.stats == null) {
          return const Center(
            child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent),
          );
        }

        if (_viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_viewModel.error!, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _viewModel.fetchDashboardData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final stats = _viewModel.stats;
        if (stats == null) {
          return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.white70)));
        }

        return RefreshIndicator(
          onRefresh: _viewModel.fetchDashboardData,
          color: StartupOnboardingTheme.goldAccent,
          backgroundColor: StartupOnboardingTheme.navySurface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header is now part of the scrollable content inside the dashboard tab
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: DashboardHeader(
                    greeting: _viewModel.greeting,
                    userName: _viewModel.userName,
                    startupName: _viewModel.startupName,
                    onNotificationTap: () {},
                    onProfileTap: () {},
                  ),
                ),
              ),

              // 1. Summary Header Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SummaryProgressCard(
                    profileCompletion: stats.profileCompletion,
                    kycStatus: stats.kycStatus,
                    aiScore: stats.aiEvaluationScore,
                    onKycTap: () => _onTabTapped(1), // Switch to KYC Tab
                  ),
                ),
              ),

              // 2. Section Header
              _buildSectionHeader('Việc cần làm tiếp theo'),

              // 3. Grid of Action Tasks
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = stats.tasks[index];
                      return OngoingProjectCard(
                        task: task,
                        onTap: () {
                          if (task.category == 'Hồ sơ') {
                            _onTabTapped(4); // Switch to Profile tab
                          } else if (task.category == 'Pháp lý' || task.title.contains('KYC')) {
                            _onTabTapped(1); // Switch to Verification tab
                          } else {
                            task.onAction?.call();
                          }
                        },
                      );
                    },
                    childCount: stats.tasks.length,
                  ),
                ),
              ),

              // 4. Recent Activity Header
              _buildSectionHeader('Hoạt động gần đây'),

              // 5. Recent Activity List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ActivityItemTile(activity: stats.activities[index]);
                  },
                  childCount: stats.activities.length,
                ),
              ),

              // Footer spacing to account for FAB and Nav Bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển bộ giao diện mới.',
            style: GoogleFonts.workSans(color: StartupOnboardingTheme.slateGray),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.softIvory,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: StartupOnboardingTheme.goldAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
