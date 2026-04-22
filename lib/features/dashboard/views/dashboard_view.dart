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

import 'package:aisep_capstone_mobile/features/profile/views/startup_profile_view.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_form_view.dart';
import 'package:aisep_capstone_mobile/features/documents/views/document_list_view.dart';
import 'package:aisep_capstone_mobile/features/connections/views/connections_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/consulting_dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_discovery_view.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';
import 'package:aisep_capstone_mobile/features/evaluation/view_models/evaluation_view_model.dart';
import 'package:aisep_capstone_mobile/features/evaluation/views/evaluation_history_view.dart';
import 'package:aisep_capstone_mobile/features/evaluation/models/evaluation_models.dart';
import 'package:aisep_capstone_mobile/features/notifications/view_models/notification_view_model.dart';
import 'package:aisep_capstone_mobile/features/notifications/views/notifications_view.dart';
import 'package:aisep_capstone_mobile/features/notifications/widgets/notification_tile.dart';
import 'package:aisep_capstone_mobile/features/messages/views/chat_list_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

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
    
    // Trigger history load for AI Status card accuracy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = context.read<StartupProfileViewModel>();
      final evalVm = context.read<EvaluationViewModel>();
      final consultingVm = context.read<ConsultingViewModel>();
      
      // Load all dependencies
      Future.wait<void>([
        profileVm.loadProfile(),
        evalVm.loadHistory(profileVm.startupId),
        consultingVm.fetchMentorships(),
      ]).then((_) {
        _syncDashboardData();
      });
    });
  }

  Future<void> _syncDashboardData() async {
    if (!mounted) return;
    
    final profileVm = context.read<StartupProfileViewModel>();
    final evalVm = context.read<EvaluationViewModel>();
    final consultingVm = context.read<ConsultingViewModel>();

    final profile = profileVm.profile;
    
    // Calculate Personal Profile Score (Hồ sơ cá nhân)
    int personalFields = 0;
    if (profile.fullNameOfApplicant.isNotEmpty) personalFields++;
    if (profile.roleOfApplicant.isNotEmpty) personalFields++;
    if (profile.contactEmail.isNotEmpty) personalFields++;
    if (profile.phoneNumber.isNotEmpty) personalFields++;
    if (profile.linkedInUrl.isNotEmpty) personalFields++;
    if (profile.location.isNotEmpty) personalFields++;
    double personalScore = personalFields / 6.0;

    // Calculate KYC Progress
    double kycProgress = 0.0;
    final String kycStr = profile.kycStatus.toLowerCase();
    if (kycStr.contains('đã xác thực') || kycStr.contains('verified')) {
      kycProgress = 1.0;
    } else if (kycStr.contains('chờ') || kycStr.contains('pending')) {
      kycProgress = 0.5;
    } else if (kycStr.contains('từ chối') || kycStr.contains('rejected')) {
      kycProgress = 0.25;
    }

    // Get latest AI Score
    int? latestAiScore;
    final history = evalVm.history.where((e) => 
      (e.status == EvaluationStatus.completed || e.status == EvaluationStatus.partial_completed) 
      && e.overallScore != null
    ).toList();
    
    if (history.isNotEmpty) {
      latestAiScore = history.first.overallScore?.toInt();
    }

    await _viewModel.fetchDashboardData(
      userName: profile.fullNameOfApplicant,
      startupName: profile.startupName,
      aiScore: latestAiScore,
      advisorCount: consultingVm.usedRequests,
      advisorProgress: consultingVm.subscriptionProgress,
      kycProgress: kycProgress,
      profileProgress: personalScore,
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      // Integration: Bottom Navigation Bar is now directly in DashboardView
      bottomNavigationBar: StartupBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      // Integration: Floating Action Button in the Dashboard notch
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          onPressed: () => _onTabTapped(2), // Always go to Dashboard
          backgroundColor: _currentIndex == 2 ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(
            Icons.home_rounded,
            color: _currentIndex == 2 
                ? (Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white) 
                : Theme.of(context).primaryColor,
            size: 32,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ConnectionsView(), // Index 0: Kết nối
          const ConsultingDashboardView(), // Index 1: Tư vấn
          _buildDashboardContent(), // Index 2: Trang chủ
          ChatListView(), // Index 3: Nhắn tin
          DocumentListView(), // Index 4: Tài liệu
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading && _viewModel.stats == null) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
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
                  onPressed: _syncDashboardData,
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

        final profileVm = context.watch<StartupProfileViewModel>();
        final profile = profileVm.profile;
        final evalVm = context.watch<EvaluationViewModel>();
        final notiViewModel = context.watch<NotificationViewModel>();
        final consultingVm = context.watch<ConsultingViewModel>();

        // Calculate Personal Profile Score (Hồ sơ cá nhân)
        double personalScore = 0;
        int personalFields = 0;
        if (profile.fullNameOfApplicant.isNotEmpty) personalFields++;
        if (profile.roleOfApplicant.isNotEmpty) personalFields++;
        if (profile.contactEmail.isNotEmpty) personalFields++;
        if (profile.phoneNumber.isNotEmpty) personalFields++;
        if (profile.linkedInUrl.isNotEmpty) personalFields++;
        if (profile.location.isNotEmpty) personalFields++;
        personalScore = personalFields / 6.0;

        // Map String kycStatus to DashboardKycStatus enum
        DashboardKycStatus currentKycStatus = DashboardKycStatus.none;
        double kycProgress = 0.0;
        final String kycStr = profile.kycStatus.toLowerCase();
        if (kycStr.contains('đã xác thực') || kycStr.contains('verified')) {
          currentKycStatus = DashboardKycStatus.verified;
          kycProgress = 1.0;
        } else if (kycStr.contains('chờ') || kycStr.contains('pending')) {
          currentKycStatus = DashboardKycStatus.pending;
          kycProgress = 0.5;
        } else if (kycStr.contains('từ chối') || kycStr.contains('rejected')) {
          currentKycStatus = DashboardKycStatus.rejected;
          kycProgress = 0.25;
        }

        // Get latest AI Score from history
        int? latestAiScore;
        final latestEval = evalVm.history.firstWhere(
          (e) => (e.status == EvaluationStatus.completed || e.status == EvaluationStatus.partial_completed) && e.overallScore != null,
          orElse: () => EvaluationStatusResult(
            runId: 0, startupId: 0, status: EvaluationStatus.queued, 
            submittedAt: DateTime.now(), updatedAt: DateTime.now()
          ),
        );
        if (latestEval.runId != 0) {
          latestAiScore = latestEval.overallScore?.toInt();
        }

        final isEvaluating = evalVm.history.any((e) => 
          e.status == EvaluationStatus.processing || e.status == EvaluationStatus.queued
        );

        return RefreshIndicator(
          onRefresh: () async {
            // Làm mới song song Dashboard và Thông báo
            await Future.wait<dynamic>([
              profileVm.loadProfile(force: true),
              evalVm.loadHistory(profileVm.startupId),
              consultingVm.fetchMentorships(),
              notiViewModel.refresh(),
            ]);
            
            // Re-fetch dashboard data with new values
            await _syncDashboardData();
          },
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: DashboardHeader(
                    greeting: _viewModel.greeting,
                    userName: profile.fullNameOfApplicant,
                    startupName: profile.startupName,
                    avatarUrl: profile.logoUrl,
                    unreadCount: notiViewModel.unreadCount,
                    onNotificationTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsView()));
                    },
                    onProfileTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StartupProfileView()));
                    },
                  ),
                ),
              ),

              // 1. Summary Header Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SummaryProgressCard(
                    title: 'Hồ sơ cá nhân',
                    profileCompletion: personalScore,
                    kycStatus: currentKycStatus,
                    aiScore: latestAiScore,
                    isAiEvaluating: isEvaluating,
                    onKycTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KycFormView(
                            isIncorporated: true,
                            onBack: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    onAiTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EvaluationHistoryView()),
                      );
                    },
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
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = stats.tasks[index];
                      return OngoingProjectCard(
                        task: task,
                        onTap: () {
                          if (task.category == 'Hồ sơ') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StartupProfileView()),
                            );
                          } else if (task.category == 'Pháp lý' || task.title.contains('KYC')) {
                            // Link to KYC via Navigator.push instead of tab change
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KycFormView(
                                  isIncorporated: true,
                                  onBack: () => Navigator.pop(context),
                                ),
                              ),
                            );
                          } else if (task.category == 'Tư vấn') {
                            _onTabTapped(1); // Switch to Consulting tab
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
                    final notification = notiViewModel.notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NotificationsView()),
                        );
                      },
                      onLongPress: () {},
                    );
                  },
                  childCount: notiViewModel.notifications.length,
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
          Icon(icon, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển bộ giao diện mới.',
            style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
    );
  }
}
