import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../messages/view_models/chat_view_model.dart';
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
  void initState() {
    super.initState();
    // Trigger a refresh when the user enters the hub to ensure data is up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConnectionViewModel().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel();

    return DefaultTabController(
      length: 3,
      child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: const Text('Kết nối'),
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
                tabAlignment: TabAlignment.center,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
                labelStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Khám phá'),
                  Tab(text: 'Đã nhận'),
                  Tab(text: 'Đã gửi'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildInterestedList(viewModel),
                _buildReceivedList(viewModel),
                _buildSentList(viewModel),
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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: TextField(
                    style: GoogleFonts.workSans(
                      color: Theme.of(context).textTheme.bodyLarge?.color, 
                      fontSize: 13,
                    ),
                    onChanged: vm.setSearchQuery,
                    decoration: InputDecoration(
                      icon: Icon(LucideIcons.search, size: 18, color: Theme.of(context).primaryColor),
                      hintText: 'Tìm nhà đầu tư...',
                      hintStyle: GoogleFonts.workSans(
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
                      ),
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Icon(LucideIcons.sliders, color: Theme.of(context).primaryColor, size: 18),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Investor List
        Expanded(
          child: vm.discoveryResults.isEmpty && vm.searchQuery.isNotEmpty
              ? _buildEmptyState('Không tìm thấy nhà đầu tư phù hợp.')
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
    
    final vm = ConnectionViewModel.instance;
    final chatVm = Provider.of<ChatViewModel>(context, listen: false);
    
    return RefreshIndicator(
      onRefresh: () async {
        await vm.refreshAll();
        await chatVm.refresh();
      },
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final rawConnection = items[index];
          final connection = vm.enrichConnection(rawConnection);
          return ConnectionRequestCard(
            connection: connection,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConnectionRequestDetailView(connection: connection),
                ),
              ).then((_) => vm.refreshAll()); // Refresh when coming back
            },
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final vm = ConnectionViewModel();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc nâng cao',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      vm.resetFilters();
                      setSheetState(() {});
                    },
                    child: Text('Thiết lập lại', style: GoogleFonts.workSans(color: theme.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildFilterDropdown(
                context, 
                'Giai đoạn', 
                ConnectionViewModel.stagesOptions,
                vm.selectedStages.firstOrNull,
                (val) {
                  if (val != null) {
                    vm.toggleStage(val);
                    setSheetState(() {});
                  }
                }
              ),
              const SizedBox(height: 16),

              _buildFilterDropdown(
                context, 
                'Ngành nghề ưu tiên', 
                ConnectionViewModel.industriesOptions,
                vm.selectedIndustries.firstOrNull,
                (val) {
                  if (val != null) {
                    vm.toggleIndustry(val);
                    setSheetState(() {});
                  }
                }
              ),
              const SizedBox(height: 16),

              _buildFilterDropdown(
                context, 
                'Quy mô đầu tư', 
                ConnectionViewModel.dealSizeOptions,
                vm.selectedDealSize,
                (val) {
                  vm.setSelectedDealSize(val);
                  setSheetState(() {});
                }
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Áp dụng bộ lọc', 
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, 
                      color: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, 
    String label, 
    List<String> options, 
    String? selectedValue,
    Function(String?) onChanged
  ) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: theme.primaryColor.withOpacity(0.5),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showSelectionModal(context, label, options, selectedValue, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue ?? 'Chọn $label',
                    style: GoogleFonts.workSans(
                      color: selectedValue != null ? textColor : textColor.withOpacity(0.3),
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronDown, size: 16, color: theme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionModal(
    BuildContext context, 
    String title, 
    List<String> options, 
    String? selectedValue,
    Function(String?) onChanged
  ) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prominent Drag Handle
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: options.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == selectedValue;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        // Small delay to show the splash effect
                        onChanged(option);
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) Navigator.pop(context);
                      },
                      splashColor: Colors.black.withOpacity(0.1),
                      highlightColor: Colors.black.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.workSans(
                                  fontSize: 13,
                                  color: isSelected ? theme.primaryColor : textColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected) 
                              Icon(Icons.check_circle, color: theme.primaryColor, size: 18),
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

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Theme.of(context).primaryColor.withOpacity(0.5)),
    );
  }

  Widget _buildSheetChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(fontSize: 13, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color),
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
            Icon(LucideIcons.inbox, size: 64, color: Theme.of(context).dividerColor),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4)),
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
