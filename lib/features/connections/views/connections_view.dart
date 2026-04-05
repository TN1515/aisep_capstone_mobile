import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/connection_request_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'connection_request_detail_view.dart';
import 'investor_profile_view.dart';
import 'favorite_investors_view.dart';
import '../widgets/investor_discovery_card.dart';
import '../models/investor_model.dart';
import '../models/connection_model.dart';

class ConnectionsView extends StatefulWidget {
  const ConnectionsView({Key? key}) : super(key: key);

  @override
  State<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel();

    return DefaultTabController(
      length: 4,
      child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: StartupOnboardingTheme.navyBg,
            appBar: AppBar(
              backgroundColor: StartupOnboardingTheme.navyBg,
              elevation: 0,
              centerTitle: false,
              title: Text(
                'Kết nối',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.softIvory,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.heart, color: const Color(0xFFEF4444)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoriteInvestorsView()),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: StartupOnboardingTheme.goldAccent,
                indicatorWeight: 3,
                labelColor: StartupOnboardingTheme.goldAccent,
                unselectedLabelColor: StartupOnboardingTheme.softIvory.withOpacity(0.4),
                labelStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Khám phá'),
                  Tab(text: 'Đã nhận'),
                  Tab(text: 'Đã gửi'),
                  Tab(text: 'Lịch sử'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildInterestedList(viewModel),
                _buildReceivedList(viewModel),
                _buildSentList(viewModel),
                _buildHistoryList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInterestedList(ConnectionViewModel vm) {
    return Column(
      children: [
        // Search & Filter Header
        Padding(
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
                    style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory, fontSize: 13),
                    onChanged: vm.setSearchQuery,
                    decoration: InputDecoration(
                      icon: const Icon(LucideIcons.search, size: 18, color: StartupOnboardingTheme.goldAccent),
                      hintText: 'Tìm nhà đầu tư...',
                      hintStyle: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.2)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showFilterSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StartupOnboardingTheme.navySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.sliders, color: StartupOnboardingTheme.goldAccent, size: 18),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Investor List
        Expanded(
          child: vm.discoveryResults.isEmpty && vm.searchQuery.isNotEmpty
              ? _buildEmptyState('Không tìm thấy nhà đầu tư phù hợp.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: vm.discoveryResults.length,
                  itemBuilder: (context, index) {
                    return _buildInterestedItem(vm.discoveryResults[index]);
                  },
                ),
        ),
      ],
    );
  }


  Widget _buildInterestedItem(InvestorModel inv) {
    return InvestorDiscoveryCard(
      investor: inv,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvestorProfileView(investor: inv)),
        );
      },
    );
  }

  Widget _buildReceivedList(ConnectionViewModel vm) {
    return _buildRequestList(vm.receivedRequests, 'Chưa có yêu cầu nào nhận được.');
  }

  Widget _buildSentList(ConnectionViewModel vm) {
    return _buildRequestList(vm.sentRequests, 'Bạn chưa gửi yêu cầu kết nối nào.');
  }

  Widget _buildHistoryList(ConnectionViewModel vm) {
    return _buildRequestList(vm.history, 'Lịch sử kết nối trống.');
  }

  Widget _buildRequestList(List<ConnectionModel> items, String emptyMsg) {
    if (items.isEmpty) return _buildEmptyState(emptyMsg);
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final connection = items[index];
        return ConnectionRequestCard(
          connection: connection,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConnectionRequestDetailView(connection: connection),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final vm = ConnectionViewModel();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StartupOnboardingTheme.navyBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => AnimatedBuilder(
        animation: vm,
        builder: (context, _) => Container(
          padding: EdgeInsets.fromLTRB(32, 24, 32, MediaQuery.of(context).padding.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc nâng cao',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: StartupOnboardingTheme.softIvory),
                    ),
                    TextButton(
                      onPressed: () => vm.resetFilters(),
                      child: Text('Thiết lập lại', style: GoogleFonts.workSans(color: StartupOnboardingTheme.goldAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildFilterLabel('GIAI ĐOẠN ĐẦU TƯ'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSheetChip('Seed', vm.selectedStages.contains('Seed'), () => vm.toggleStage('Seed')),
                    _buildSheetChip('Series A', vm.selectedStages.contains('Series A'), () => vm.toggleStage('Series A')),
                    _buildSheetChip('Series B', vm.selectedStages.contains('Series B'), () => vm.toggleStage('Series B')),
                    _buildSheetChip('IPO', vm.selectedStages.contains('IPO'), () => vm.toggleStage('IPO')),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilterLabel('LĨNH VỰC'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSheetChip('AI & Data', vm.selectedIndustries.contains('AI & Data'), () => vm.toggleIndustry('AI & Data')),
                    _buildSheetChip('Fintech', vm.selectedIndustries.contains('Fintech'), () => vm.toggleIndustry('Fintech')),
                    _buildSheetChip('EdTech', vm.selectedIndustries.contains('EdTech'), () => vm.toggleIndustry('EdTech')),
                    _buildSheetChip('Blockchain', vm.selectedIndustries.contains('Blockchain'), () => vm.toggleIndustry('Blockchain')),
                  ],
                ),
                const SizedBox(height: 32),
                _buildFilterLabel('QUY MÔ ĐẦU TƯ'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSheetChip('< \$500k', vm.selectedDealSize == '< \$500k', () => vm.setSelectedDealSize('< \$500k')),
                    _buildSheetChip('\$500k - \$2M', vm.selectedDealSize == '\$500k - \$2M', () => vm.setSelectedDealSize('\$500k - \$2M')),
                    _buildSheetChip('\$2M+', vm.selectedDealSize == '\$2M+', () => vm.setSelectedDealSize('\$2M+')),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StartupOnboardingTheme.goldAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Áp dụng bộ lọc', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: StartupOnboardingTheme.navyBg)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
    );
  }

  Widget _buildSheetChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? StartupOnboardingTheme.goldAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? StartupOnboardingTheme.goldAccent : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(fontSize: 13, color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 64, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to simplify ListView padding
extension ListViewPadding on ListView {
  static ListView padding({required EdgeInsets padding, required List<Widget> children}) {
    return ListView(padding: padding, children: children);
  }
}
