import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/investor_discovery_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'investor_profile_view.dart';

class InvestorDiscoveryView extends StatefulWidget {
  const InvestorDiscoveryView({Key? key}) : super(key: key);

  @override
  State<InvestorDiscoveryView> createState() => _InvestorDiscoveryViewState();
}

class _InvestorDiscoveryViewState extends State<InvestorDiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Tìm nhà đầu tư'),
          ),
          body: Column(
            children: [
              // Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.workSans(color: textColor),
                          onChanged: viewModel.setSearchQuery,
                          decoration: InputDecoration(
                            icon: Icon(LucideIcons.search, size: 20, color: theme.primaryColor),
                            hintText: 'Tên, quỹ, lĩnh vực...',
                            hintStyle: GoogleFonts.workSans(color: textColor.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showFilterSheet(context, viewModel),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Icon(LucideIcons.sliders, color: theme.primaryColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Filters Display
              if (viewModel.selectedStages.isNotEmpty || viewModel.selectedIndustries.isNotEmpty || viewModel.selectedDealSize != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (viewModel.selectedStages.isNotEmpty)
                        ...viewModel.selectedStages.map((s) => _QuickFilterChip(
                          label: s, 
                          isSelected: true,
                          onTap: () => viewModel.toggleStage(s),
                        )),
                      if (viewModel.selectedIndustries.isNotEmpty)
                        ...viewModel.selectedIndustries.map((i) => _QuickFilterChip(
                          label: i, 
                          isSelected: true,
                          onTap: () => viewModel.toggleIndustry(i),
                        )),
                      if (viewModel.selectedDealSize != null)
                        _QuickFilterChip(
                          label: viewModel.selectedDealSize!, 
                          isSelected: true,
                          onTap: () => viewModel.setSelectedDealSize(null),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Discovery List
              Expanded(
                child: viewModel.isLoading 
                  ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                  : viewModel.discoveryResults.isEmpty 
                    ? _buildEmptySearch(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: viewModel.discoveryResults.length,
                        itemBuilder: (context, index) {
                          final investor = viewModel.discoveryResults[index];
                          return InvestorDiscoveryCard(
                            investor: investor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => InvestorProfileView(investor: investor)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, ConnectionViewModel viewModel) {
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
                    'Bộ lọc',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      viewModel.resetFilters();
                      setSheetState(() {});
                    },
                    child: Text('Thiết lập lại', style: GoogleFonts.workSans(color: theme.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Giai đoạn
              _buildFilterDropdown(
                context, 
                'Giai đoạn', 
                ConnectionViewModel.stagesOptions,
                viewModel.selectedStages.firstOrNull,
                (val) {
                  if (val != null) {
                    viewModel.toggleStage(val);
                    setSheetState(() {});
                  }
                }
              ),
              const SizedBox(height: 16),

              // Ngành nghề ưu tiên
              _buildFilterDropdown(
                context, 
                'Ngành nghề ưu tiên', 
                ConnectionViewModel.industriesOptions,
                viewModel.selectedIndustries.firstOrNull,
                (val) {
                  if (val != null) {
                    viewModel.toggleIndustry(val);
                    setSheetState(() {});
                  }
                }
              ),
              const SizedBox(height: 16),

              // Quy mô đầu tư
              _buildFilterDropdown(
                context, 
                'Quy mô đầu tư', 
                ConnectionViewModel.dealSizeOptions,
                viewModel.selectedDealSize,
                (val) {
                  viewModel.setSelectedDealSize(val);
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
                    elevation: 0,
                  ),
                  child: Text(
                    'Áp dụng',
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

  Widget _buildEmptySearch(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 60, color: textColor.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhà đầu tư nào phù hợp.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: textColor.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _QuickFilterChip({Key? key, required this.label, this.isSelected = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                  ? (theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white)
                  : (theme.textTheme.bodyLarge?.color?.withOpacity(0.6) ?? Colors.white),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                LucideIcons.x, 
                size: 14, 
                color: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white
              ),
            ],
          ],
        ),
      ),
    );
  }
}
